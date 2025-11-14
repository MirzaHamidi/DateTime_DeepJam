extends Node3D

## Bisiklet sürücüsü için IK (Inverse Kinematics) kontrol scripti
## Bu script, Skeleton3D üzerinde TwoBoneIK kullanarak ayak ve el pozisyonlarını kontrol eder.

# ============================================================================
# EXPORT AYARLARI
# ============================================================================

@export_group("Skeleton Referansı")
## Sürücü skeleton'ı (Skeleton3D node'u)
@export var rider_skeleton: Skeleton3D = null

@export_group("Bone İsimleri")
## Sol uyluk kemiği ismi (thigh_L, UpperLeg_L, vb.)
@export var left_thigh_bone: String = "thigh_L"

## Sol baldır kemiği ismi (calf_L, LowerLeg_L, vb.)
@export var left_calf_bone: String = "calf_L"

## Sol ayak kemiği ismi (foot_L, Foot_L, vb.)
@export var left_foot_bone: String = "foot_L"

## Sağ uyluk kemiği ismi
@export var right_thigh_bone: String = "thigh_R"

## Sağ baldır kemiği ismi
@export var right_calf_bone: String = "calf_R"

## Sağ ayak kemiği ismi
@export var right_foot_bone: String = "foot_R"

## Sol üst kol kemiği ismi (upperarm_L, UpperArm_L, vb.)
@export var left_upperarm_bone: String = "upperarm_L"

## Sol ön kol kemiği ismi (forearm_L, LowerArm_L, vb.)
@export var left_forearm_bone: String = "forearm_L"

## Sol el kemiği ismi (hand_L, Hand_L, vb.)
@export var left_hand_bone: String = "hand_L"

## Sağ üst kol kemiği ismi
@export var right_upperarm_bone: String = "upperarm_R"

## Sağ ön kol kemiği ismi
@export var right_forearm_bone: String = "forearm_R"

## Sağ el kemiği ismi
@export var right_hand_bone: String = "hand_R"

@export_group("IK Hedefleri")
## Sol ayak hedefi (Node3D)
@export var left_foot_target: Node3D = null

## Sağ ayak hedefi (Node3D)
@export var right_foot_target: Node3D = null

## Sol el hedefi (Node3D - gidon tutamağı)
@export var left_hand_target: Node3D = null

## Sağ el hedefi (Node3D - gidon tutamağı)
@export var right_hand_target: Node3D = null

# ============================================================================
# NODE REFERANSLARI
# ============================================================================

## IK hedefleri düğümü (BikeController'dan alınacak)
@onready var ik_targets_node: Node3D = get_node_or_null("../IKTargets")

# ============================================================================
# DEĞİŞKENLER
# ============================================================================

## Skeleton modification stack referansı
var modification_stack: SkeletonModificationStack3D = null

## Sol bacak IK modifikasyonu
var left_leg_ik: SkeletonModification3DTwoBoneIK = null

## Sağ bacak IK modifikasyonu
var right_leg_ik: SkeletonModification3DTwoBoneIK = null

## Sol kol IK modifikasyonu
var left_arm_ik: SkeletonModification3DTwoBoneIK = null

## Sağ kol IK modifikasyonu
var right_arm_ik: SkeletonModification3DTwoBoneIK = null

# ============================================================================
# READY
# ============================================================================

func _ready() -> void:
	# Skeleton referansını bul
	if rider_skeleton == null:
		rider_skeleton = get_node_or_null("../Skeleton3D")
	
	if rider_skeleton == null:
		push_error("BikeIKController: Skeleton3D bulunamadı! Lütfen rider_skeleton export değişkenini ayarlayın.")
		return
	
	# IK hedeflerini bul
	_setup_ik_targets()
	
	# Skeleton modification stack'i oluştur ve ayarla
	_setup_ik_system()

# ============================================================================
# IK HEDEFLERİNİ AYARLA
# ============================================================================

## IK hedef node'larını bulur ve referansları ayarlar
func _setup_ik_targets() -> void:
	if ik_targets_node:
		if left_foot_target == null:
			left_foot_target = ik_targets_node.get_node_or_null("LeftFootTarget")
		if right_foot_target == null:
			right_foot_target = ik_targets_node.get_node_or_null("RightFootTarget")
		if left_hand_target == null:
			left_hand_target = ik_targets_node.get_node_or_null("LeftHandTarget")
		if right_hand_target == null:
			right_hand_target = ik_targets_node.get_node_or_null("RightHandTarget")
	
	# Hedefler bulunamazsa uyarı ver
	if left_foot_target == null:
		push_warning("BikeIKController: LeftFootTarget bulunamadı!")
	if right_foot_target == null:
		push_warning("BikeIKController: RightFootTarget bulunamadı!")
	if left_hand_target == null:
		push_warning("BikeIKController: LeftHandTarget bulunamadı!")
	if right_hand_target == null:
		push_warning("BikeIKController: RightHandTarget bulunamadı!")

# ============================================================================
# IK SİSTEMİNİ AYARLA
# ============================================================================

## SkeletonModificationStack3D ve TwoBoneIK modifikasyonlarını oluşturur ve yapılandırır
func _setup_ik_system() -> void:
	# Skeleton'da modification stack var mı kontrol et
	modification_stack = rider_skeleton.skeleton_modification_stack
	
	# Eğer yoksa, yeni bir tane oluştur
	if modification_stack == null:
		modification_stack = SkeletonModificationStack3D.new()
		rider_skeleton.skeleton_modification_stack = modification_stack
	
	# Stack'i aktif et
	modification_stack.enabled = true
	
	# IK modifikasyonlarını oluştur
	_setup_leg_ik()
	_setup_arm_ik()

# ============================================================================
# BACAK IK AYARLARI
# ============================================================================

## Sol ve sağ bacaklar için TwoBoneIK modifikasyonlarını oluşturur
func _setup_leg_ik() -> void:
	# Sol bacak IK
	left_leg_ik = _create_two_bone_ik(
		left_thigh_bone,
		left_calf_bone,
		left_foot_bone,
		left_foot_target,
		"LeftLegIK"
	)
	
	# Sağ bacak IK
	right_leg_ik = _create_two_bone_ik(
		right_thigh_bone,
		right_calf_bone,
		right_foot_bone,
		right_foot_target,
		"RightLegIK"
	)

# ============================================================================
# KOL IK AYARLARI
# ============================================================================

## Sol ve sağ kollar için TwoBoneIK modifikasyonlarını oluşturur
func _setup_arm_ik() -> void:
	# Sol kol IK
	left_arm_ik = _create_two_bone_ik(
		left_upperarm_bone,
		left_forearm_bone,
		left_hand_bone,
		left_hand_target,
		"LeftArmIK"
	)
	
	# Sağ kol IK
	right_arm_ik = _create_two_bone_ik(
		right_upperarm_bone,
		right_forearm_bone,
		right_hand_bone,
		right_hand_target,
		"RightArmIK"
	)

# ============================================================================
# TWO BONE IK OLUŞTUR
# ============================================================================

## Generic TwoBoneIK modifikasyonu oluşturur ve stack'e ekler
## 
## Parameters:
##   - bone_root_name: İlk kemik ismi (ör: thigh_L)
##   - bone_mid_name: İkinci kemik ismi (ör: calf_L)
##   - bone_tip_name: Son kemik ismi (ör: foot_L)
##   - target_node: IK hedef node'u
##   - ik_name: IK modifikasyonunun ismi (debug için)
##
## Returns: Oluşturulan SkeletonModification3DTwoBoneIK referansı
func _create_two_bone_ik(
	bone_root_name: String,
	bone_mid_name: String,
	bone_tip_name: String,
	target_node: Node3D,
	ik_name: String
) -> SkeletonModification3DTwoBoneIK:
	# Hedef node yoksa null döndür
	if target_node == null:
		push_warning("BikeIKController: " + ik_name + " için hedef node bulunamadı!")
		return null
	
	# Yeni TwoBoneIK modifikasyonu oluştur
	var ik_mod: SkeletonModification3DTwoBoneIK = SkeletonModification3DTwoBoneIK.new()
	ik_mod.name = ik_name
	
	# Kemik ID'lerini bul
	var root_bone_id: int = rider_skeleton.find_bone(bone_root_name)
	var mid_bone_id: int = rider_skeleton.find_bone(bone_mid_name)
	var tip_bone_id: int = rider_skeleton.find_bone(bone_tip_name)
	
	# Kemikler bulunamazsa uyarı ver
	if root_bone_id == -1:
		push_warning("BikeIKController: Kemik bulunamadı: " + bone_root_name)
		return null
	if mid_bone_id == -1:
		push_warning("BikeIKController: Kemik bulunamadı: " + bone_mid_name)
		return null
	if tip_bone_id == -1:
		push_warning("BikeIKController: Kemik bulunamadı: " + bone_tip_name)
		return null
	
	# Kemik ID'lerini ayarla
	ik_mod.root_bone_idx = root_bone_id
	ik_mod.mid_bone_idx = mid_bone_id
	ik_mod.tip_bone_idx = tip_bone_id
	
	# Hedef node'u ayarla
	# Not: Godot 4.5.1'de target_node_path kullanılıyor
	ik_mod.target_node = get_path_to(target_node)
	
	# IK ayarları
	ik_mod.use_tip_node = false  # Sadece target_node kullan
	ik_mod.auto_calculate_joint_length = true  # Otomatik eklem uzunluğu hesapla
	
	# Modifikasyonu stack'e ekle
	modification_stack.add_modification(ik_mod)
	
	# Modifikasyonu aktif et
	ik_mod.enabled = true
	
	print("BikeIKController: " + ik_name + " başarıyla oluşturuldu ve aktif edildi.")
	
	return ik_mod

# ============================================================================
# UPDATE (Her frame'de hedefleri güncelle)
# ============================================================================

func _process(_delta: float) -> void:
	# IK sisteminin çalışması için skeleton'ın güncellenmesi gerekiyor
	# Bu işlem otomatik olarak SkeletonModificationStack tarafından yapılıyor
	# Ancak hedef node'ların pozisyonlarını güncellemek için burada bir şey yapmamıza gerek yok
	# Çünkü BikeController zaten pedal pozisyonlarını güncelliyor
	pass

# ============================================================================
# YARDIMCI FONKSİYONLAR
# ============================================================================

## IK sistemini aktif/pasif yapar
func set_ik_enabled(enabled: bool) -> void:
	if modification_stack:
		modification_stack.enabled = enabled

## Belirli bir IK modifikasyonunu aktif/pasif yapar
func set_ik_modification_enabled(ik_name: String, enabled: bool) -> void:
	if modification_stack == null:
		return
	
	for i in range(modification_stack.modification_count):
		var mod = modification_stack.get_modification(i)
		if mod != null and mod.name == ik_name:
			mod.enabled = enabled
			break


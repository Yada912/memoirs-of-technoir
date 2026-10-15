class_name ChapterData
extends Resource

## ChapterData Custom Resource
## Fully decoupled data specification for chapters/levels in Memoirs of Technoir.
## Adding a new chapter only requires instantiating this resource without touching logic scenes.

@export_group("Identification")
@export var chapter_id: String = "chapter_1"
@export var chapter_number: int = 1
@export var chapter_title: String = "Chapter 1 - Prologue"
@export var subtitle: String = "where the Silence Lives"
@export var device_name: String = "Vintage Desk Fan (Model 1978)"
@export_multiline var objective_text: String = "Unfasten 4 cage screws, remove front guard and blade assembly, clean the jammed motor bearing, reassemble and test run."

@export_group("Narrative Webtoon Content")
## Array of dictionaries representing sequential webtoon comic panels.
## Format: { "text": String, "speaker": String, "mood": String, "tone_color": Color }
@export var narrative_panels: Array[Dictionary] = [
	{
		"title": "Prologue : where the Silence Lives",
		"paragraphs": [
			"Di pojok kamar yang sempit...",
			"partikel cahaya rembulan yang menembus jendela menari pelan di udara yang diam.",
			"Lampu meja belajar menyala redup."
		],
		"bg_tone": Color("0d1017"),
		"mood": "solitude"
	},
	{
		"title": "Sakelar dan Debu",
		"paragraphs": [
			"Di atasnya terdapat sebuah perangkat lawas yang casingnya mulai kusam dan berdebu.",
			"Kipas meja peninggalan keluarga yang berhenti berputar bertahun-tahun lalu."
		],
		"bg_tone": Color("16141a"),
		"mood": "nostalgia"
	},
	{
		"title": "Teman Bicara",
		"paragraphs": [
			"Benda ini pernah menjadi saksi bisu perjuangan Tara di masa-masa sulit.",
			"Sempat ia menyimpan pembicaraan-pembicaraan kecil, dan isi hatinya di hembusan anginnya yang sejuk.",
			"\"Malam ini... aku akan membuatmu berputar lagi.\""
		],
		"bg_tone": Color("241d20"),
		"mood": "determination"
	}
]

@export_group("3D Inspection Environment")
@export var target_model_scene: PackedScene
@export var ambient_light_color: Color = Color("232029")
@export var lamp_color: Color = Color("ffe0b2")
@export var lamp_energy: float = 3.2
@export var workbench_wood_color: Color = Color("382921")
@export var bgm_preset: String = "late_night_lofi"

class ShotModel {
  final int id;
  final int playerid;
  final int shotid;
  final int frequency;
  final double efficiency;
  ShotModel(
      {required this.id,
      required this.playerid,
      required this.shotid,
      required this.frequency,
      required this.efficiency});
  factory ShotModel.fromMap(Map<String, dynamic> map) => ShotModel(
      id: int.parse(map['id']),
      playerid: int.parse(map['player_id']),
      shotid: int.parse(map['shot_id']),
      frequency: int.parse(map['shot_frequency']),
      efficiency: double.parse(map['efficiency']));

  Map<String, dynamic> toMap() => {
        "playerid": playerid,
        "shotid": shotid,
        "frequency": frequency,
        "efficiency": efficiency
      };
}

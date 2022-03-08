// ignore_for_file: file_names

class ShotProfileModel {
  final int id;
  final String shotname;
  final int frequency;
  final double efficiency;
  ShotProfileModel(
      {required this.id,
      required this.shotname,
      required this.frequency,
      required this.efficiency});
  factory ShotProfileModel.fromMap(Map<String, dynamic> map) =>
      ShotProfileModel(
          id: int.parse(map['id']),
          shotname: map['shot_name'],
          frequency: int.parse(map['shot_frequency']),
          efficiency: double.parse(map['efficiency']));

  Map<String, dynamic> toMap() =>
      {"shot_name": shotname, "frequency": frequency, "efficiency": efficiency};
}

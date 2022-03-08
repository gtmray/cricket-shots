class SampleAnalysis {
  final int id;
  final String name;
  final String src;
  SampleAnalysis({required this.id, required this.name, required this.src});
  factory SampleAnalysis.fromMap(Map<String, dynamic> map) => SampleAnalysis(
      id: int.parse(map['id']), name: map['name'], src: map['src']);
  Map<String, dynamic> toMap() => {'name': name, "src": src};
}

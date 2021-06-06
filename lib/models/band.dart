class Band {
  final String id;
  final String name;
   int votes;
  
  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(
        id: obj['id'], 
        name: obj['name'], 
        votes: obj['votes']
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'votes': votes,
    };
  }
}
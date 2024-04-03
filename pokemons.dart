class Pokemons {
  final String name;
  final String url;

  Pokemons({
    required this.name,
    required this.url,
  });

  factory Pokemons.fromJson(Map<String, dynamic> json) {
    return Pokemons(
      name: json['name'],
      url: json['url'],
    );
  }
}

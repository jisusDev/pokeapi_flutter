import "package:pokeapi_application/widgets/widgets.dart";

class FavoritePokemonScreen extends StatefulWidget {
  final List<Pokemons> favoritePokemonList;
  final Color Function(String) getColorForType;

  const FavoritePokemonScreen({
    Key? key,
    required this.favoritePokemonList,
    required this.getColorForType,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FavoritePokemonScreenState createState() => _FavoritePokemonScreenState();
}

class _FavoritePokemonScreenState extends State<FavoritePokemonScreen> {
  bool _isListView = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Pokemons'),
        actions: [
          IconButton(
            icon: _isListView
                ? const Icon(Icons.grid_view)
                : const Icon(Icons.list),
            onPressed: () {
              setState(
                () {
                  _isListView = !_isListView;
                },
              );
            },
          ),
        ],
      ),
      body: _isListView
          ? ListView.builder(
              itemCount: widget.favoritePokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = widget.favoritePokemonList[index];
                widget.getColorForType(pokemon.types[0].type.name);
                return ListTile(
                  leading: Image.network(
                      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png"),
                  title: Text(pokemon.name),
                  subtitle: Text('ID: ${pokemon.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.yellow),
                    onPressed: () {
                      setState(() {
                        widget.favoritePokemonList.removeAt(index);
                      });
                    },
                  ),
                );
              },
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: widget.favoritePokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = widget.favoritePokemonList[index];
                final color =
                    widget.getColorForType(pokemon.types[0].type.name);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(
                          pokemon: pokemon,
                          favoritePokemonList: widget.favoritePokemonList,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2.0,
                    color: color,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png",
                          height: 110,
                        ),
                        const SizedBox(height: 10),
                        Text(pokemon.name),
                        Text('ID: ${pokemon.id}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

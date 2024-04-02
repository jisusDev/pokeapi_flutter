import "package:pokeapi_application/widgets/widgets.dart";

void main() => runApp(const ListScreen());

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class PokemonTypeFilter extends StatelessWidget implements PreferredSizeWidget {
  final List<String> pokemonTypes;
  final Function(String) onTypeSelected;
  final Pokemons pokemon;

  const PokemonTypeFilter({
    super.key,
    required this.pokemonTypes,
    required this.onTypeSelected,
    required this.pokemon,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: pokemonTypes
          .map(
            (type) => ElevatedButton(
              onPressed: () {
                onTypeSelected(type);
              },
              child: Text(type),
            ),
          )
          .toList(),
    );
  }
}

class _ListScreenState extends State<ListScreen> {
  List<Pokemons> pokemonList = [];
  List<Pokemons> favoritePokemonList = [];
  List<String> pokemonTypes = [];
  List<Pokemons> filteredPokemonList = [];

  final TextEditingController _typeController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPokemon();
  }

  Future<void> getPokemon() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoritePokemonIds = prefs.getStringList('favoritePokemonIds');

  final response = await Dio().get("https://pokeapi.co/api/v2/pokemon?limit=20");

  final List<dynamic> results = response.data['results'];
  List<Future<Response>> pokemonFutures =
      results.map((pokemonData) => Dio().get(pokemonData['url'])).toList();

  List<Response> pokemonResponses = await Future.wait(pokemonFutures);

  pokemonList = pokemonResponses
      .map((pokemonResponse) => Pokemons.fromJson(pokemonResponse.data))
      .toList();

  pokemonTypes = pokemonList
      .map((pokemon) => pokemon.types[0].type.name)
      .toSet()
      .toList();

  favoritePokemonList = favoritePokemonIds != null
      ? pokemonList
          .where((pokemon) => favoritePokemonIds.contains(pokemon.id.toString()))
          .toList()
      : [];


  setState(() {
    isLoading = false;
  });
}

  Color getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color.fromARGB(255, 255, 110, 100);
      case 'water':
        return const Color.fromARGB(255, 94, 182, 255);
      case 'grass':
        return const Color.fromARGB(255, 93, 208, 97);
      case 'electric':
        return const Color.fromARGB(255, 255, 212, 82);
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.orange;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lime;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.deepPurple;
      case 'dark':
        return Colors.brown;
      case 'dragon':
        return Colors.deepPurple;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  List<Pokemons> filterPokemonsByType(String type) {
    return pokemonList
        .where((pokemon) => pokemon.types.any((t) => t.type.name == type))
        .toList();
  }

  void searchByType(String type) {
    setState(() {
      if (type.isEmpty) {
        filteredPokemonList = List<Pokemons>.from(pokemonList);
      } else {
        filteredPokemonList = filterPokemonsByType(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: TextField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      hintText: 'Search by the type of Pokemon',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          searchByType(_typeController.text.toLowerCase());
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      searchByType(value.toLowerCase());
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritePokemonScreen(
                              favoritePokemonList: favoritePokemonList,
                              getColorForType: getColorForType,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  floating: true,
                  pinned: false,
                  snap: true,
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'Pokedex',
                      style:
                          TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final pokemon = filteredPokemonList.isNotEmpty
                          ? filteredPokemonList[index]
                          : pokemonList[index];
                      final color = getColorForType(pokemon.types[0].type.name);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailScreen(
                                pokemon: pokemon,
                                favoritePokemonList: favoritePokemonList,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3.0,
                          color: color,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image:
                                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png",
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                pokemon.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('ID: ${pokemon.id}'),
                              Container(
                                width: 20,
                                height: 20,
                                color:
                                    getColorForType(pokemon.types[0].type.name),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredPokemonList.isNotEmpty
                        ? filteredPokemonList.length
                        : pokemonList.length,
                  ),
                ),
              ],
            ),
            if (isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      'assets/loading.gif',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

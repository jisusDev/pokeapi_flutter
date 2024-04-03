import "package:pokeapi_application/widgets/widgets.dart";
import 'package:http/http.dart' as http;

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
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> results = jsonData['results'];

        List<Future<http.Response>> futures = results.map((result) {
          return http.get(Uri.parse(result['url']));
        }).toList();

        final List<http.Response> responses = await Future.wait(futures);

        for (var response in responses) {
          if (response.statusCode == 200) {
            final pokemonData = json.decode(response.body);
            final pokemon = Pokemons.fromJson(pokemonData);
            setState(() {
              pokemonList.add(pokemon);
              filteredPokemonList = List<Pokemons>.from(pokemonList);
            });
          }
        }

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load pokemons');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching pokemons: $error');
    }
  }

  List<Pokemons> filterPokemonsByName(String name) {
    return pokemonList
        .where((pokemon) => pokemon.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  void searchByName(String name) {
    setState(() {
      if (name.isEmpty) {
        filteredPokemonList = List<Pokemons>.from(pokemonList);
      } else {
        filteredPokemonList = filterPokemonsByName(name);
      }
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
                          searchByName(_typeController.text.toLowerCase());
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      searchByName(value.toLowerCase());
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
              color: Colors.green.shade500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: "assets/pokeball.png",
                    image:
                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${index + 1}.png",
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pokemon.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('URL: ${pokemon.url}'),
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

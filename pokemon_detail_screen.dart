import "package:pokeapi_application/widgets/widgets.dart";

class PokemonDetailScreen extends StatefulWidget {
  final Pokemons pokemon;
  final List<Pokemons> favoritePokemonList;

  const PokemonDetailScreen({
    Key? key,
    required this.pokemon,
    required this.favoritePokemonList,
  }) : super(key: key);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool isFavorite = false;
  bool showFrontImage = true;
  int currentIndex = 0;
  late Timer _imageTimer;

  Color getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getDarkerColor(Color color) {
    return color.withOpacity(0.7);
  }

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          showFrontImage = !showFrontImage;
        });
      }
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    super.dispose();
  }

  Widget _buildAboutSection() {
    var width = MediaQuery.of(context).size.width;
    double heightInInches = widget.pokemon.height * 3.93701;
    double weightInKg = widget.pokemon.weight * 0.1;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width * 0.5,
                child: const Text(
                  'Name',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  widget.pokemon.name,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width * 0.5,
                child: const Text(
                  'Height',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  '${heightInInches.toStringAsFixed(2)} inches',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width * 0.5,
                child: const Text(
                  'Weight',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  '${weightInKg.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color appBarColor = getColorForType(widget.pokemon.types[0].type.name);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          widget.pokemon.name,
          style: const TextStyle(fontSize: 25),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.yellow : Colors.white,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              setState(() {
                isFavorite = !isFavorite;
                if (isFavorite) {
                  widget.favoritePokemonList.add(widget.pokemon);
                  prefs.setStringList(
                      'favoritePokemonIds',
                      widget.favoritePokemonList
                          .map((e) => e.id.toString())
                          .toList());
                } else {
                  widget.favoritePokemonList.remove(widget.pokemon);
                  prefs.setStringList(
                      'favoritePokemonIds',
                      widget.favoritePokemonList
                          .map((e) => e.id.toString())
                          .toList());
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth,
            color: appBarColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.pokemon.id}.png",
                width: 100,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildAboutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

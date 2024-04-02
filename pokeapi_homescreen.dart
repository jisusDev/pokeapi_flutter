import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokeapi_application/screens/pokeapi_listscreen.dart';

void main() => runApp(const HomePokemon());

class HomePokemon extends StatefulWidget {
  const HomePokemon({super.key});

  @override
  State<HomePokemon> createState() => _HomePokemonState();
}

class _HomePokemonState extends State<HomePokemon> {
  late Color _backgroundColor;
  double _progressValue = 0.0;
  late Timer _colorTimer;

  @override
  void initState() {
    super.initState();
    _backgroundColor = Colors.blue;
    _startColorAnimation();
    _startLoading();
  }

  void _startColorAnimation() {
    _colorTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        setState(() {
          _backgroundColor =
              _backgroundColor == Colors.blue ? Colors.red : Colors.blue;
        });
      }
    });
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progressValue += 0.01;
        if (_progressValue >= 1.0) {
          timer.cancel();
          _navigateToListScreen();
        }
      });
    });
  }

  void _navigateToListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ListScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _colorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pokescreen.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(157, 255, 255, 255)),
                      child: Text(
                        "Poke Api",
                        style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: _backgroundColor),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Poke Api",
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = _backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_backgroundColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 247, 245, 245)),
                    child: const Text(
                      'Cargando...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 174, 255),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

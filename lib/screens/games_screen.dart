import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'game_screen.dart';
import 'hunt_screen.dart';
import 'magic_tiles_screen.dart';
import 'race_screen.dart';
import 'sprint_screen.dart';
import '../widgets/app_card.dart';

/// The six typing games.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;

    void open(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.gamesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          _GameCard(
            icon: Icons.water_drop_outlined,
            name: t.gameName,
            description: t.gameDescription,
            best: state.bestFor('word-rain'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const GameScreen()),
          ),
          _GameCard(
            icon: Icons.bubble_chart_outlined,
            name: t.letterPopName,
            description: t.letterPopDescription,
            best: state.bestFor('letter-pop'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const GameScreen(mode: GameMode.letters)),
          ),
          _GameCard(
            icon: Icons.flag_outlined,
            name: t.raceName,
            description: t.raceDescription,
            best: state.bestFor('speed-race'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const RaceScreen()),
          ),
          _GameCard(
            icon: Icons.keyboard_alt_outlined,
            name: t.huntName,
            description: t.huntDescription,
            best: state.bestFor('key-hunt'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const HuntScreen()),
          ),
          _GameCard(
            icon: Icons.piano_rounded,
            name: t.magicTilesName,
            description: t.magicTilesDescription,
            best: state.bestFor('magic-tiles'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const MagicTilesScreen()),
          ),
          _GameCard(
            icon: Icons.timer_outlined,
            name: t.sprintName,
            description: t.sprintDescription,
            best: state.bestFor('word-sprint'),
            bestLabel: t.gameBestScore,
            playLabel: t.playGame,
            onPlay: () => open(const SprintScreen()),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.name,
    required this.description,
    required this.best,
    required this.bestLabel,
    required this.playLabel,
    required this.onPlay,
  });

  final IconData icon;
  final String name;
  final String description;
  final int best;
  final String bestLabel;
  final String playLabel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 40, color: theme.colorScheme.primary),
        title: Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('$description  ($bestLabel: $best)'),
        trailing: FilledButton(onPressed: onPlay, child: Text(playLabel)),
      ),
    );
  }
}

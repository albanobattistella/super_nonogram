///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsIt extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsIt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <it>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsIt _root = this; // ignore: unused_field

	@override 
	TranslationsIt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsIt(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsTitleIt title = _TranslationsTitleIt._(_root);
	@override late final _TranslationsSearchIt search = _TranslationsSearchIt._(_root);
	@override late final _TranslationsPlayIt play = _TranslationsPlayIt._(_root);
	@override late final _TranslationsSettingsIt settings = _TranslationsSettingsIt._(_root);
	@override late final _TranslationsGameModesIt gameModes = _TranslationsGameModesIt._(_root);
}

// Path: title
class _TranslationsTitleIt extends TranslationsTitleEn {
	_TranslationsTitleIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Super Nonogram';
	@override String get playLevels => 'Gioca\nlivelli';
	@override String get playImages => 'Gioca\nimmagini';
	@override String get playClassic => 'Gioca\nclassico';
	@override String get achievements => 'Obiettivi';
}

// Path: search
class _TranslationsSearchIt extends TranslationsSearchEn {
	_TranslationsSearchIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get createNewPuzzle => 'Crea un puzzle';
	@override String get enterPrompt => 'Inserisci un prompt';
	@override String get prompt => 'Prompt';
	@override String get failedToGenerateBoard => 'Generazione griglia fallita, prova un altro prompt';
	@override String get create => 'Crea';
	@override TextSpan privacyInformation({required InlineSpanBuilder link}) => TextSpan(children: [
		const TextSpan(text: 'Il tuo prompt verrà inviato a Pixabay, un sito di condivisione immagini gratuito, per recuperare un\'immagine pertinente.\nConsulta la nostra '),
		link('Privacy Policy'),
		const TextSpan(text: ' per maggiori informazioni.'),
	]);
}

// Path: play
class _TranslationsPlayIt extends TranslationsPlayEn {
	_TranslationsPlayIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String level({required Object n}) => 'Livello ${n}';
	@override String levelCompleted({required Object n}) => 'Livello ${n} completato!';
	@override String get puzzleCompleted => 'Puzzle completato!';
	@override String get nextLevel => 'Livello successivo';
	@override String get restartLevel => 'Ricomincia livello';
	@override String get restartPuzzle => 'Ricomincia puzzle';
	@override String get playAgain => 'Gioca ancora';
	@override String get backToTitlePage => 'Torna al menu';
	@override TextSpan imageAttribution({required InlineSpan author, required InlineSpan pixabay}) => TextSpan(children: [
		const TextSpan(text: 'Immagine di '),
		author,
		const TextSpan(text: ' da '),
		pixabay,
	]);
}

// Path: settings
class _TranslationsSettingsIt extends TranslationsSettingsEn {
	_TranslationsSettingsIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get settings => 'Impostazioni';
	@override String get hyperlegibleFont => 'Usa font Atkinson Hyperlegible';
	@override String get hyperlegibleFontDescription => 'Più leggibile per persone con vista ridotta';
	@override String get useHapticFeedback => 'Usa feedback aptico';
	@override String get useHapticFeedbackDescription => 'Vibra leggermente quando tocchi la griglia';
	@override String get about => 'Tocca qui per maggiori informazioni sull\'app';
	@override String get legalese => 'Super Nonogram  Copyright (C) 2025  Adil Hanney\nQuesto programma viene fornito assolutamente senza garanzia. Questo è software libero, e sei il benvenuto a ridistribuirlo sotto determinate condizioni.';
}

// Path: gameModes
class _TranslationsGameModesIt extends TranslationsGameModesEn {
	_TranslationsGameModesIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get level => 'Livelli';
	@override String get classic => 'Classico';
	@override String get image => 'Immagine';
}

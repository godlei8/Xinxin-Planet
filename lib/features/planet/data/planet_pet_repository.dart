import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/planet_pet.dart';

class PlanetPetRepository {
  static const _storageKey = 'planet_pet_profile_v1';

  Future<PlanetPet> getPet() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final pet = PlanetPet.createDefault();
      await savePet(pet);
      return pet;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid pet payload');
      }
      return PlanetPet.fromMap(decoded);
    } catch (_) {
      final pet = PlanetPet.createDefault();
      await savePet(pet);
      return pet;
    }
  }

  Future<void> savePet(PlanetPet pet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(pet.toMap()));
  }
}

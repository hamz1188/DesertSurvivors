//
//  AwakeningManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

struct AwakeningRecipe {
    let baseWeaponName: String
    let passiveItemName: String
    let factory: () -> BaseWeapon
    let awakenedName: String
    let description: String
}

class AwakeningManager {
    static let shared = AwakeningManager()
    
    private var recipes: [AwakeningRecipe] = []
    
    private init() {
        setupRecipes()
    }
    
    private func setupRecipes() {
        recipes = [
            AwakeningRecipe(
                baseWeaponName: "Curved Dagger",
                passiveItemName: "Sandstorm Cloak",
                factory: { WhirlwindOfBlades() },
                awakenedName: "Whirlwind of Blades",
                description: "Evolved Curved Dagger. Throws a spiral of piercing blades."
            ),
            AwakeningRecipe(
                baseWeaponName: "Sand Bolt",
                passiveItemName: "Djinn's Lamp",
                factory: { DesertStorm() },
                awakenedName: "Desert Storm",
                description: "Evolved Sand Bolt. Fires rapid explosive bolts."
            ),
            AwakeningRecipe(
                baseWeaponName: "Scorpion Tail",
                passiveItemName: "Venom Vial",
                factory: { EmperorScorpion() },
                awakenedName: "Emperor Scorpion",
                description: "Evolved Scorpion Tail. Dual whips with lethal poison."
            ),
            AwakeningRecipe(
                baseWeaponName: "Sun Ray",
                passiveItemName: "Scarab Amulet",
                factory: { WrathOfTheSun() },
                awakenedName: "Wrath of the Sun",
                description: "Evolved Sun Ray. Massive rotating solar beams."
            ),
            AwakeningRecipe(
                baseWeaponName: "Dust Devil",
                passiveItemName: "Sandstorm Cloak",
                factory: { Haboob() },
                awakenedName: "Haboob",
                description: "Evolved Dust Devil. Massive sandstorms that devour enemies."
            ),
            AwakeningRecipe(
                baseWeaponName: "Mirage Clone",
                passiveItemName: "Mirror of Truth",
                factory: { ArmyOfMirages() },
                awakenedName: "Army of Mirages",
                description: "Evolved Mirage Clone. A squad of explosive illusions."
            ),
            AwakeningRecipe(
                baseWeaponName: "Oil Flask",
                passiveItemName: "Djinn Lamp",
                factory: { GreekFire() },
                awakenedName: "Greek Fire",
                description: "Evolved Oil Flask. Intense spreading poison fire."
            ),
            AwakeningRecipe(
                baseWeaponName: "Desert Eagle",
                passiveItemName: "Eagle Feather",
                factory: { RocsDescendant() },
                awakenedName: "Roc's Descendant",
                description: "Evolved Desert Eagle. Summons a legendary shockwave bird."
            ),
            AwakeningRecipe(
                baseWeaponName: "Sandstorm Shield",
                passiveItemName: "Desert Rose",
                factory: { EyeOfTheStorm() },
                awakenedName: "Eye of the Storm",
                description: "Evolved Shield. Impenetrable electric storm barrier."
            ),
            AwakeningRecipe(
                baseWeaponName: "Ancient Curse",
                passiveItemName: "Canopic Jar",
                factory: { PharaohsWrath() },
                awakenedName: "Pharaoh's Wrath",
                description: "Evolved Curse. Seals enemies to drain life and explode."
            ),
            AwakeningRecipe(
                baseWeaponName: "Quicksand",
                passiveItemName: "Hourglass",
                factory: { DevouringSands() },
                awakenedName: "Devouring Sands",
                description: "Evolved Quicksand. Massive sinkholes that devour weak foes."
            ),
            AwakeningRecipe(
                baseWeaponName: "Djinn's Flame",
                passiveItemName: "Djinn Lamp",
                factory: { IfritsEmbrace() },
                awakenedName: "Ifrit's Embrace",
                description: "Evolved Djinn's Flame. Ring of living fire and seeking spirits."
            )
            // Add more recipes here as we implement them
        ]
    }
    
    func checkAwakening(weapon: BaseWeapon, passives: [PassiveItem]) -> AwakeningRecipe? {
        // Weapon must be max level (8)
        guard weapon.level >= 8 else { return nil }
        
        // Find recipe for this weapon
        guard let recipe = recipes.first(where: { $0.baseWeaponName == weapon.weaponName }) else { return nil }
        
        // Check if player has the required passive
        if passives.contains(where: { $0.name == recipe.passiveItemName }) {
            return recipe
        }
        
        return nil
    }
    
    func getAwakenedWeapon(for recipe: AwakeningRecipe) -> BaseWeapon {
        let weapon = recipe.factory()
        weapon.isAwakened = true
        return weapon
    }
}

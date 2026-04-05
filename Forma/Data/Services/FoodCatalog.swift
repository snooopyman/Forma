//
//  FoodCatalog.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation

enum FoodCatalog {

    // MARK: - Catalog (~250 items, values per 100 g)

    static var catalog: [FoodItem] { [

        // MARK: Carne y Aves

        FoodItem(name: "Pechuga de pollo",               category: "Carne",           mainMacro: .protein, caloriesPer100g:  97, proteinPer100g: 22.0, carbsPer100g:  0.0, fatPer100g:  1.0, basePortionG: 150),
        FoodItem(name: "Muslo de pollo",                 category: "Carne",           mainMacro: .protein, caloriesPer100g: 177, proteinPer100g: 18.0, carbsPer100g:  0.0, fatPer100g: 11.0, basePortionG: 150),
        FoodItem(name: "Alitas de pollo",                category: "Carne",           mainMacro: .protein, caloriesPer100g: 263, proteinPer100g: 23.0, carbsPer100g:  0.0, fatPer100g: 19.0, basePortionG: 150),
        FoodItem(name: "Pollo frito",                    category: "Carne",           mainMacro: .protein, caloriesPer100g: 290, proteinPer100g: 20.0, carbsPer100g: 12.0, fatPer100g: 18.0, basePortionG: 150),
        FoodItem(name: "Pavo",                           category: "Carne",           mainMacro: .protein, caloriesPer100g: 105, proteinPer100g: 24.0, carbsPer100g:  0.0, fatPer100g:  1.0, basePortionG: 150),
        FoodItem(name: "Pechuga de pavo 92% Hacendado",  category: "Carne",           mainMacro: .protein, caloriesPer100g:  91, proteinPer100g: 19.5, carbsPer100g:  1.0, fatPer100g:  1.3, basePortionG: 150),
        FoodItem(name: "Carne de vacuno magra",          category: "Carne",           mainMacro: .protein, caloriesPer100g: 176, proteinPer100g: 26.0, carbsPer100g:  0.0, fatPer100g:  8.0, basePortionG: 150),
        FoodItem(name: "Ternera",                        category: "Carne",           mainMacro: .protein, caloriesPer100g: 194, proteinPer100g: 26.0, carbsPer100g:  0.0, fatPer100g: 10.0, basePortionG: 150),
        FoodItem(name: "Buey magro",                     category: "Carne",           mainMacro: .protein, caloriesPer100g: 169, proteinPer100g: 22.0, carbsPer100g:  0.0, fatPer100g:  9.0, basePortionG: 150),
        FoodItem(name: "Carne de cerdo magra",           category: "Carne",           mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 21.0, carbsPer100g:  0.0, fatPer100g:  9.0, basePortionG: 150),
        FoodItem(name: "Lomo de cerdo",                  category: "Carne",           mainMacro: .protein, caloriesPer100g: 148, proteinPer100g: 22.0, carbsPer100g:  0.0, fatPer100g:  7.0, basePortionG: 150),
        FoodItem(name: "Codorniz",                       category: "Carne",           mainMacro: .protein, caloriesPer100g: 137, proteinPer100g: 23.0, carbsPer100g:  0.0, fatPer100g:  5.0, basePortionG: 150),
        FoodItem(name: "Pato",                           category: "Carne",           mainMacro: .protein, caloriesPer100g: 175, proteinPer100g: 19.0, carbsPer100g:  0.0, fatPer100g: 11.0, basePortionG: 150),
        FoodItem(name: "Conejo",                         category: "Carne",           mainMacro: .protein, caloriesPer100g: 111, proteinPer100g: 21.0, carbsPer100g:  0.0, fatPer100g:  3.0, basePortionG: 150),
        FoodItem(name: "Hamburguesa Diet Pollo",         category: "Carne",           mainMacro: .protein, caloriesPer100g: 142, proteinPer100g: 20.0, carbsPer100g:  2.0, fatPer100g:  6.0, basePortionG: 125),
        FoodItem(name: "Hamburguesa Diet Ternera",       category: "Carne",           mainMacro: .protein, caloriesPer100g: 164, proteinPer100g: 22.0, carbsPer100g:  1.0, fatPer100g:  8.0, basePortionG: 125),
        FoodItem(name: "Hamburguesa Diet Pavo",          category: "Carne",           mainMacro: .protein, caloriesPer100g: 129, proteinPer100g: 18.0, carbsPer100g:  3.0, fatPer100g:  5.0, basePortionG: 125),
        FoodItem(name: "Hamburguesa Diet Buey",          category: "Carne",           mainMacro: .protein, caloriesPer100g: 186, proteinPer100g: 23.0, carbsPer100g:  1.0, fatPer100g: 10.0, basePortionG: 125),

        // MARK: Pescado y Marisco

        FoodItem(name: "Atún en agua",                   category: "Pescado",         mainMacro: .protein, caloriesPer100g: 101, proteinPer100g: 23.0, carbsPer100g:  0.0, fatPer100g:  1.0, basePortionG: 120),
        FoodItem(name: "Salmón",                         category: "Pescado",         mainMacro: .protein, caloriesPer100g: 197, proteinPer100g: 20.0, carbsPer100g:  0.0, fatPer100g: 13.0, basePortionG: 150),
        FoodItem(name: "Trucha",                         category: "Pescado",         mainMacro: .protein, caloriesPer100g: 143, proteinPer100g: 20.0, carbsPer100g:  0.0, fatPer100g:  7.0, basePortionG: 150),
        FoodItem(name: "Bacalao",                        category: "Pescado",         mainMacro: .protein, caloriesPer100g:  81, proteinPer100g: 18.0, carbsPer100g:  0.0, fatPer100g:  1.0, basePortionG: 150),
        FoodItem(name: "Filete de merluza",              category: "Pescado",         mainMacro: .protein, caloriesPer100g:  93, proteinPer100g: 15.0, carbsPer100g:  0.8, fatPer100g:  2.9, basePortionG: 150),
        FoodItem(name: "Caballa",                        category: "Pescado",         mainMacro: .protein, caloriesPer100g: 197, proteinPer100g: 20.0, carbsPer100g:  0.0, fatPer100g: 13.0, basePortionG: 150),
        FoodItem(name: "Sardinas en aceite",             category: "Pescado",         mainMacro: .protein, caloriesPer100g: 199, proteinPer100g: 25.0, carbsPer100g:  0.0, fatPer100g: 11.0, basePortionG: 100),
        FoodItem(name: "Sardina fresca",                 category: "Pescado",         mainMacro: .protein, caloriesPer100g: 183, proteinPer100g: 21.0, carbsPer100g:  0.0, fatPer100g: 11.0, basePortionG: 150),
        FoodItem(name: "Anchoas",                        category: "Pescado",         mainMacro: .protein, caloriesPer100g: 157, proteinPer100g: 29.0, carbsPer100g:  0.0, fatPer100g:  4.5, basePortionG: 50),
        FoodItem(name: "Gambas",                         category: "Pescado",         mainMacro: .protein, caloriesPer100g: 110, proteinPer100g: 24.0, carbsPer100g:  0.0, fatPer100g:  1.5, basePortionG: 150),
        FoodItem(name: "Langostinos",                    category: "Pescado",         mainMacro: .protein, caloriesPer100g: 110, proteinPer100g: 24.0, carbsPer100g:  0.0, fatPer100g:  1.5, basePortionG: 150),
        FoodItem(name: "Mejillones",                     category: "Pescado",         mainMacro: .protein, caloriesPer100g:  69, proteinPer100g: 10.5, carbsPer100g:  3.7, fatPer100g:  2.2, basePortionG: 200),
        FoodItem(name: "Calamares",                      category: "Pescado",         mainMacro: .protein, caloriesPer100g:  89, proteinPer100g: 15.6, carbsPer100g:  3.1, fatPer100g:  1.4, basePortionG: 150),
        FoodItem(name: "Pulpo cocido",                   category: "Pescado",         mainMacro: .protein, caloriesPer100g:  89, proteinPer100g: 16.0, carbsPer100g:  4.0, fatPer100g:  1.0, basePortionG: 150),
        FoodItem(name: "Sepia",                          category: "Pescado",         mainMacro: .protein, caloriesPer100g:  93, proteinPer100g: 15.0, carbsPer100g:  3.0, fatPer100g:  0.7, basePortionG: 150),
        FoodItem(name: "Ostras",                         category: "Pescado",         mainMacro: .protein, caloriesPer100g:  74, proteinPer100g:  9.0, carbsPer100g:  5.0, fatPer100g:  2.0, basePortionG: 100),

        // MARK: Lácteos y Huevos

        FoodItem(name: "Huevos enteros",                 category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 155, proteinPer100g: 13.0, carbsPer100g:  1.1, fatPer100g: 11.0, basePortionG: 120),
        FoodItem(name: "Claras de huevo",                category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  49, proteinPer100g: 11.0, carbsPer100g:  0.7, fatPer100g:  0.2, basePortionG: 200),
        FoodItem(name: "Claras de huevo en polvo",       category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 361, proteinPer100g: 81.0, carbsPer100g:  7.0, fatPer100g:  1.0, basePortionG: 30),
        FoodItem(name: "Leche entera",                   category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  64, proteinPer100g:  3.3, carbsPer100g:  4.8, fatPer100g:  3.5, basePortionG: 250),
        FoodItem(name: "Leche semidesnatada",             category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  47, proteinPer100g:  3.4, carbsPer100g:  4.8, fatPer100g:  1.6, basePortionG: 250),
        FoodItem(name: "Yogur natural",                  category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  71, proteinPer100g:  5.0, carbsPer100g:  4.0, fatPer100g:  3.0, basePortionG: 125),
        FoodItem(name: "Yogur griego 2%",                category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  76, proteinPer100g: 10.0, carbsPer100g:  4.0, fatPer100g:  2.0, basePortionG: 150),
        FoodItem(name: "Yogur griego 10%",               category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 130, proteinPer100g: 10.0, carbsPer100g:  4.0, fatPer100g: 10.0, basePortionG: 150),
        FoodItem(name: "Yogur +Proteínas Natural",       category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  57, proteinPer100g: 10.0, carbsPer100g:  3.1, fatPer100g:  0.5, basePortionG: 200),
        FoodItem(name: "Yogur +Proteínas Coco",          category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  60, proteinPer100g:  8.3, carbsPer100g:  5.7, fatPer100g:  0.5, basePortionG: 200),
        FoodItem(name: "Queso fresco",                   category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  85, proteinPer100g: 10.0, carbsPer100g:  3.0, fatPer100g:  4.0, basePortionG: 100),
        FoodItem(name: "Queso fresco 0%",                category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  57, proteinPer100g: 10.0, carbsPer100g:  4.0, fatPer100g:  0.2, basePortionG: 100),
        FoodItem(name: "Queso fresco burgos 0%",         category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  70, proteinPer100g: 12.1, carbsPer100g:  3.9, fatPer100g:  0.5, basePortionG: 100),
        FoodItem(name: "Queso cottage",                  category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 14.0, carbsPer100g:  1.7, fatPer100g:  4.0, basePortionG: 100),
        FoodItem(name: "Requesón",                       category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g:  92, proteinPer100g: 11.0, carbsPer100g:  3.0, fatPer100g:  4.0, basePortionG: 100),
        FoodItem(name: "Queso curado",                   category: "Lácteos y Huevos", mainMacro: .fat,     caloriesPer100g: 431, proteinPer100g: 25.0, carbsPer100g:  1.8, fatPer100g: 36.0, basePortionG: 30),
        FoodItem(name: "Queso tierno",                   category: "Lácteos y Huevos", mainMacro: .fat,     caloriesPer100g: 391, proteinPer100g: 21.5, carbsPer100g:  0.1, fatPer100g: 33.9, basePortionG: 40),
        FoodItem(name: "Queso mozzarella",               category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 307, proteinPer100g: 26.0, carbsPer100g:  3.8, fatPer100g: 20.0, basePortionG: 50),
        FoodItem(name: "Queso feta",                     category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 222, proteinPer100g: 14.0, carbsPer100g:  4.0, fatPer100g: 21.0, basePortionG: 50),
        FoodItem(name: "Queso ricotta",                  category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 174, proteinPer100g: 11.0, carbsPer100g:  3.0, fatPer100g: 10.0, basePortionG: 100),
        FoodItem(name: "Natillas +Proteínas",            category: "Lácteos y Huevos", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 12.0, carbsPer100g:  7.0, fatPer100g:  1.8, basePortionG: 125),

        // MARK: Cereales y Pan

        FoodItem(name: "Arroz blanco cocido",            category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 127, proteinPer100g:  2.7, carbsPer100g: 28.2, fatPer100g:  0.3, fiberPer100g: 0.4, basePortionG: 200),
        FoodItem(name: "Arroz integral cocido",          category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 105, proteinPer100g:  2.6, carbsPer100g: 23.0, fatPer100g:  1.0, fiberPer100g: 1.8, basePortionG: 200),
        FoodItem(name: "Arroz basmati cocido",           category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 126, proteinPer100g:  2.5, carbsPer100g: 28.0, fatPer100g:  0.3, fiberPer100g: 0.4, basePortionG: 200),
        FoodItem(name: "Pasta cocida",                   category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 130, proteinPer100g:  5.0, carbsPer100g: 25.0, fatPer100g:  1.1, fiberPer100g: 1.8, basePortionG: 200),
        FoodItem(name: "Pasta integral cocida",          category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 130, proteinPer100g:  5.0, carbsPer100g: 25.0, fatPer100g:  1.2, fiberPer100g: 3.0, basePortionG: 200),
        FoodItem(name: "Gnocchi",                        category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 173, proteinPer100g:  4.5, carbsPer100g: 37.6, fatPer100g:  0.4, basePortionG: 200),
        FoodItem(name: "Cuscús cocido",                  category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 113, proteinPer100g:  3.8, carbsPer100g: 23.0, fatPer100g:  0.6, basePortionG: 180),
        FoodItem(name: "Quinoa cocida",                  category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 119, proteinPer100g:  4.4, carbsPer100g: 21.3, fatPer100g:  1.9, fiberPer100g: 2.8, basePortionG: 180),
        FoodItem(name: "Quinoa cruda",                   category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 370, proteinPer100g: 14.0, carbsPer100g: 64.0, fatPer100g:  6.0, fiberPer100g: 7.0, basePortionG: 70),
        FoodItem(name: "Bulgur cocido",                  category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g:  84, proteinPer100g:  3.0, carbsPer100g: 18.0, fatPer100g:  0.0, fiberPer100g: 3.0, basePortionG: 180),
        FoodItem(name: "Avena (copos)",                  category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 392, proteinPer100g: 13.5, carbsPer100g: 66.3, fatPer100g:  7.0, fiberPer100g: 11.0, basePortionG: 80),
        FoodItem(name: "Avena instantánea",              category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 379, proteinPer100g: 13.0, carbsPer100g: 59.0, fatPer100g:  7.0, fiberPer100g: 8.0, basePortionG: 80),
        FoodItem(name: "Harina de avena",                category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 375, proteinPer100g: 12.0, carbsPer100g: 60.0, fatPer100g:  7.0, fiberPer100g: 9.0, basePortionG: 50),
        FoodItem(name: "Harina de trigo",                category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 361, proteinPer100g: 10.0, carbsPer100g: 76.0, fatPer100g:  1.5, fiberPer100g: 3.0, basePortionG: 50),
        FoodItem(name: "Harina integral de trigo",       category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 354, proteinPer100g: 12.0, carbsPer100g: 70.0, fatPer100g:  2.0, fiberPer100g: 8.0, basePortionG: 50),
        FoodItem(name: "Copos de espelta",               category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 355, proteinPer100g: 12.0, carbsPer100g: 68.0, fatPer100g:  3.0, fiberPer100g: 9.0, basePortionG: 70),
        FoodItem(name: "Trigo sarraceno cocido",         category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 101, proteinPer100g:  3.4, carbsPer100g: 20.0, fatPer100g:  0.8, fiberPer100g: 2.7, basePortionG: 180),
        FoodItem(name: "Mijo cocido",                    category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 112, proteinPer100g:  3.5, carbsPer100g: 23.0, fatPer100g:  1.1, fiberPer100g: 1.3, basePortionG: 180),
        FoodItem(name: "Amaranto cocido",                category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 103, proteinPer100g:  3.8, carbsPer100g: 19.0, fatPer100g:  1.2, fiberPer100g: 2.1, basePortionG: 180),
        FoodItem(name: "Cebada cocida",                  category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 132, proteinPer100g:  3.5, carbsPer100g: 28.0, fatPer100g:  0.7, fiberPer100g: 3.8, basePortionG: 180),
        FoodItem(name: "Pan integral",                   category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 238, proteinPer100g:  9.0, carbsPer100g: 45.0, fatPer100g:  2.0, fiberPer100g: 6.0, basePortionG: 60),
        FoodItem(name: "Pan blanco",                     category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 265, proteinPer100g:  9.0, carbsPer100g: 50.0, fatPer100g:  3.0, fiberPer100g: 2.3, basePortionG: 60),
        FoodItem(name: "Pan de centeno",                 category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 235, proteinPer100g:  8.0, carbsPer100g: 48.0, fatPer100g:  3.0, fiberPer100g: 6.0, basePortionG: 60),
        FoodItem(name: "Pan 55% centeno",                category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 116, proteinPer100g:  4.5, carbsPer100g: 16.0, fatPer100g:  3.5, basePortionG: 60),
        FoodItem(name: "Pan de molde blanco",            category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 220, proteinPer100g:  9.4, carbsPer100g: 43.0, fatPer100g:  2.6, basePortionG: 60),
        FoodItem(name: "Pan de molde integral",          category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 214, proteinPer100g:  9.0, carbsPer100g: 45.0, fatPer100g:  2.0, fiberPer100g: 5.0, basePortionG: 60),
        FoodItem(name: "Pan de pita integral",           category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 261, proteinPer100g:  9.0, carbsPer100g: 55.0, fatPer100g:  1.0, fiberPer100g: 5.0, basePortionG: 70),
        FoodItem(name: "Pan de espelta",                 category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 255, proteinPer100g: 10.0, carbsPer100g: 48.0, fatPer100g:  2.5, fiberPer100g: 5.0, basePortionG: 60),
        FoodItem(name: "Pan sin gluten",                 category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 266, proteinPer100g:  7.0, carbsPer100g: 55.0, fatPer100g:  2.0, basePortionG: 60),
        FoodItem(name: "Bagel",                          category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 265, proteinPer100g:  9.0, carbsPer100g: 55.0, fatPer100g:  1.0, basePortionG: 90),
        FoodItem(name: "Tortitas de maíz",               category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 143, proteinPer100g:  2.3, carbsPer100g: 27.0, fatPer100g:  3.0, basePortionG: 30),
        FoodItem(name: "Tortitas de arroz",              category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 365, proteinPer100g:  8.5, carbsPer100g: 75.0, fatPer100g:  2.8, basePortionG: 30),
        FoodItem(name: "Cereales de desayuno",           category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 372, proteinPer100g:  7.0, carbsPer100g: 84.0, fatPer100g:  0.9, basePortionG: 40),
        FoodItem(name: "Cereales integrales",            category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 332, proteinPer100g:  9.0, carbsPer100g: 66.0, fatPer100g:  4.0, fiberPer100g: 8.0, basePortionG: 40),
        FoodItem(name: "Muesli",                         category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 415, proteinPer100g:  8.0, carbsPer100g: 70.0, fatPer100g:  7.0, fiberPer100g: 6.0, basePortionG: 60),
        FoodItem(name: "Puré de patata instantáneo",     category: "Cereales y Pan",   mainMacro: .carbs, caloriesPer100g: 391, proteinPer100g:  7.0, carbsPer100g: 80.0, fatPer100g:  3.0, basePortionG: 50),

        // MARK: Legumbres

        FoodItem(name: "Lentejas cocidas",               category: "Legumbres",       mainMacro: .carbs, caloriesPer100g: 123, proteinPer100g:  9.0, carbsPer100g: 20.0, fatPer100g:  0.8, fiberPer100g: 7.9, basePortionG: 200),
        FoodItem(name: "Garbanzos cocidos",              category: "Legumbres",       mainMacro: .carbs, caloriesPer100g: 171, proteinPer100g:  8.9, carbsPer100g: 27.4, fatPer100g:  2.6, fiberPer100g: 7.6, basePortionG: 200),
        FoodItem(name: "Alubias blancas cocidas",        category: "Legumbres",       mainMacro: .carbs, caloriesPer100g: 131, proteinPer100g:  8.7, carbsPer100g: 22.9, fatPer100g:  0.5, fiberPer100g: 6.3, basePortionG: 200),
        FoodItem(name: "Alubias rojas cocidas",          category: "Legumbres",       mainMacro: .carbs, caloriesPer100g: 133, proteinPer100g:  8.5, carbsPer100g: 23.0, fatPer100g:  0.8, fiberPer100g: 7.4, basePortionG: 200),
        FoodItem(name: "Guisantes cocidos",              category: "Legumbres",       mainMacro: .carbs, caloriesPer100g:  80, proteinPer100g:  5.0, carbsPer100g: 14.0, fatPer100g:  0.4, fiberPer100g: 5.0, basePortionG: 150),
        FoodItem(name: "Soja cocida",                    category: "Legumbres",       mainMacro: .protein, caloriesPer100g: 166, proteinPer100g: 16.0, carbsPer100g:  9.0, fatPer100g:  6.0, fiberPer100g: 6.0, basePortionG: 150),
        FoodItem(name: "Edamame",                        category: "Legumbres",       mainMacro: .protein, caloriesPer100g: 121, proteinPer100g: 11.0, carbsPer100g:  8.0, fatPer100g:  5.0, fiberPer100g: 5.2, basePortionG: 150),
        FoodItem(name: "Tofu firme",                     category: "Legumbres",       mainMacro: .protein, caloriesPer100g: 120, proteinPer100g: 12.0, carbsPer100g:  2.0, fatPer100g:  6.0, basePortionG: 150),
        FoodItem(name: "Tempeh",                         category: "Legumbres",       mainMacro: .protein, caloriesPer100g: 213, proteinPer100g: 19.0, carbsPer100g:  9.0, fatPer100g: 11.0, fiberPer100g: 4.0, basePortionG: 100),
        FoodItem(name: "Seitán",                         category: "Legumbres",       mainMacro: .protein, caloriesPer100g: 128, proteinPer100g: 25.0, carbsPer100g:  5.0, fatPer100g:  2.0, basePortionG: 100),

        // MARK: Verduras

        FoodItem(name: "Espinacas",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  27, proteinPer100g:  2.9, carbsPer100g:  3.6, fatPer100g:  0.4, fiberPer100g: 2.2, basePortionG: 200),
        FoodItem(name: "Brócoli",                        category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  43, proteinPer100g:  2.8, carbsPer100g:  7.0, fatPer100g:  0.4, fiberPer100g: 2.6, basePortionG: 200),
        FoodItem(name: "Kale",                           category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  49, proteinPer100g:  3.0, carbsPer100g:  9.0, fatPer100g:  0.5, fiberPer100g: 3.6, basePortionG: 100),
        FoodItem(name: "Acelga",                         category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  24, proteinPer100g:  1.8, carbsPer100g:  4.0, fatPer100g:  0.2, fiberPer100g: 1.6, basePortionG: 200),
        FoodItem(name: "Lechuga",                        category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  18, proteinPer100g:  1.4, carbsPer100g:  2.9, fatPer100g:  0.2, fiberPer100g: 1.3, basePortionG: 100),
        FoodItem(name: "Rúcula",                         category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  34, proteinPer100g:  2.6, carbsPer100g:  3.7, fatPer100g:  0.7, fiberPer100g: 1.6, basePortionG: 80),
        FoodItem(name: "Tomate",                         category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  20, proteinPer100g:  0.9, carbsPer100g:  3.9, fatPer100g:  0.2, fiberPer100g: 1.2, basePortionG: 150),
        FoodItem(name: "Tomate cherry",                  category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  22, proteinPer100g:  1.0, carbsPer100g:  4.0, fatPer100g:  0.2, fiberPer100g: 1.2, basePortionG: 150),
        FoodItem(name: "Pepino",                         category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  17, proteinPer100g:  0.6, carbsPer100g:  3.5, fatPer100g:  0.1, fiberPer100g: 0.5, basePortionG: 150),
        FoodItem(name: "Zanahoria",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  43, proteinPer100g:  0.9, carbsPer100g: 10.0, fatPer100g:  0.2, fiberPer100g: 2.8, basePortionG: 150),
        FoodItem(name: "Pimiento rojo",                  category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  31, proteinPer100g:  1.0, carbsPer100g:  6.0, fatPer100g:  0.3, fiberPer100g: 2.1, basePortionG: 150),
        FoodItem(name: "Pimiento verde",                 category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  22, proteinPer100g:  1.0, carbsPer100g:  4.0, fatPer100g:  0.2, fiberPer100g: 1.7, basePortionG: 150),
        FoodItem(name: "Berenjena",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  30, proteinPer100g:  1.0, carbsPer100g:  6.0, fatPer100g:  0.2, fiberPer100g: 3.4, basePortionG: 200),
        FoodItem(name: "Calabacín",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  20, proteinPer100g:  1.2, carbsPer100g:  3.1, fatPer100g:  0.3, fiberPer100g: 1.1, basePortionG: 200),
        FoodItem(name: "Coliflor",                       category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  31, proteinPer100g:  2.0, carbsPer100g:  5.0, fatPer100g:  0.3, fiberPer100g: 2.0, basePortionG: 200),
        FoodItem(name: "Champiñones",                    category: "Verduras",        mainMacro: .protein, caloriesPer100g:  28, proteinPer100g:  3.1, carbsPer100g:  3.3, fatPer100g:  0.3, fiberPer100g: 1.0, basePortionG: 150),
        FoodItem(name: "Setas shiitake",                 category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  40, proteinPer100g:  2.2, carbsPer100g:  7.0, fatPer100g:  0.5, fiberPer100g: 2.5, basePortionG: 100),
        FoodItem(name: "Espárragos",                     category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  25, proteinPer100g:  2.2, carbsPer100g:  3.9, fatPer100g:  0.1, fiberPer100g: 2.1, basePortionG: 200),
        FoodItem(name: "Judías verdes",                  category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  37, proteinPer100g:  2.0, carbsPer100g:  7.0, fatPer100g:  0.1, fiberPer100g: 3.4, basePortionG: 200),
        FoodItem(name: "Patata cocida",                  category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  78, proteinPer100g:  2.0, carbsPer100g: 17.0, fatPer100g:  0.1, fiberPer100g: 2.2, basePortionG: 200),
        FoodItem(name: "Batata cocida",                  category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  87, proteinPer100g:  1.6, carbsPer100g: 20.0, fatPer100g:  0.1, fiberPer100g: 3.3, basePortionG: 200),
        FoodItem(name: "Maíz dulce cocido",              category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  99, proteinPer100g:  3.2, carbsPer100g: 18.7, fatPer100g:  1.2, fiberPer100g: 2.4, basePortionG: 150),
        FoodItem(name: "Calabaza",                       category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  33, proteinPer100g:  1.0, carbsPer100g:  7.0, fatPer100g:  0.1, fiberPer100g: 0.5, basePortionG: 200),
        FoodItem(name: "Remolacha",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  48, proteinPer100g:  1.6, carbsPer100g: 10.0, fatPer100g:  0.2, fiberPer100g: 2.8, basePortionG: 150),
        FoodItem(name: "Cebolleta",                      category: "Verduras",        mainMacro: .carbs, caloriesPer100g:  45, proteinPer100g:  1.8, carbsPer100g:  9.3, fatPer100g:  0.1, fiberPer100g: 1.8, basePortionG: 50),

        // MARK: Fruta

        FoodItem(name: "Plátano",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g: 101, proteinPer100g:  1.3, carbsPer100g: 22.8, fatPer100g:  0.3, fiberPer100g: 2.6, basePortionG: 120),
        FoodItem(name: "Manzana",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  60, proteinPer100g:  0.3, carbsPer100g: 14.0, fatPer100g:  0.2, fiberPer100g: 2.4, basePortionG: 150),
        FoodItem(name: "Naranja",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  54, proteinPer100g:  0.9, carbsPer100g: 12.0, fatPer100g:  0.1, fiberPer100g: 2.2, basePortionG: 150),
        FoodItem(name: "Pera",                           category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  63, proteinPer100g:  0.4, carbsPer100g: 15.0, fatPer100g:  0.1, fiberPer100g: 3.1, basePortionG: 150),
        FoodItem(name: "Kiwi",                           category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  69, proteinPer100g:  1.1, carbsPer100g: 15.0, fatPer100g:  0.5, fiberPer100g: 3.0, basePortionG: 100),
        FoodItem(name: "Fresas",                         category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  36, proteinPer100g:  0.7, carbsPer100g:  7.7, fatPer100g:  0.3, fiberPer100g: 2.0, basePortionG: 200),
        FoodItem(name: "Frambuesas",                     category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  56, proteinPer100g:  1.2, carbsPer100g: 12.0, fatPer100g:  0.3, fiberPer100g: 6.5, basePortionG: 100),
        FoodItem(name: "Arándanos",                      category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  62, proteinPer100g:  0.7, carbsPer100g: 14.0, fatPer100g:  0.3, fiberPer100g: 2.4, basePortionG: 100),
        FoodItem(name: "Moras",                          category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  49, proteinPer100g:  1.3, carbsPer100g: 10.0, fatPer100g:  0.4, fiberPer100g: 5.3, basePortionG: 100),
        FoodItem(name: "Cerezas",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  70, proteinPer100g:  1.0, carbsPer100g: 16.0, fatPer100g:  0.2, fiberPer100g: 2.1, basePortionG: 100),
        FoodItem(name: "Mango",                          category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  66, proteinPer100g:  0.8, carbsPer100g: 15.0, fatPer100g:  0.3, fiberPer100g: 1.6, basePortionG: 150),
        FoodItem(name: "Piña",                           category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  56, proteinPer100g:  0.5, carbsPer100g: 13.0, fatPer100g:  0.1, fiberPer100g: 1.4, basePortionG: 150),
        FoodItem(name: "Melón",                          category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  36, proteinPer100g:  0.8, carbsPer100g:  8.0, fatPer100g:  0.2, fiberPer100g: 0.9, basePortionG: 200),
        FoodItem(name: "Sandía",                         category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  35, proteinPer100g:  0.6, carbsPer100g:  8.0, fatPer100g:  0.2, fiberPer100g: 0.4, basePortionG: 200),
        FoodItem(name: "Ciruela",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  51, proteinPer100g:  0.7, carbsPer100g: 11.0, fatPer100g:  0.3, fiberPer100g: 1.4, basePortionG: 100),
        FoodItem(name: "Albaricoque",                    category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  40, proteinPer100g:  0.5, carbsPer100g:  9.0, fatPer100g:  0.1, fiberPer100g: 2.0, basePortionG: 100),
        FoodItem(name: "Nectarina",                      category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  46, proteinPer100g:  0.9, carbsPer100g: 10.0, fatPer100g:  0.3, fiberPer100g: 1.7, basePortionG: 150),
        FoodItem(name: "Higo",                           category: "Fruta",           mainMacro: .carbs, caloriesPer100g:  70, proteinPer100g:  0.8, carbsPer100g: 16.0, fatPer100g:  0.3, fiberPer100g: 2.9, basePortionG: 100),
        FoodItem(name: "Dátiles",                        category: "Fruta",           mainMacro: .carbs, caloriesPer100g: 285, proteinPer100g:  2.0, carbsPer100g: 68.9, fatPer100g:  0.5, fiberPer100g: 6.7, basePortionG: 30),
        FoodItem(name: "Coco fresco",                    category: "Fruta",           mainMacro: .fat,   caloriesPer100g: 369, proteinPer100g:  3.3, carbsPer100g: 15.0, fatPer100g: 33.0, fiberPer100g: 9.0, basePortionG: 50),

        // MARK: Grasas y Aceites

        FoodItem(name: "Aceite de oliva",                category: "Grasas",          mainMacro: .fat, caloriesPer100g: 900, proteinPer100g:  0.0, carbsPer100g:  0.0, fatPer100g: 100.0, basePortionG: 10),
        FoodItem(name: "Aceite de girasol",              category: "Grasas",          mainMacro: .fat, caloriesPer100g: 900, proteinPer100g:  0.0, carbsPer100g:  0.0, fatPer100g: 100.0, basePortionG: 10),
        FoodItem(name: "Mantequilla",                    category: "Grasas",          mainMacro: .fat, caloriesPer100g: 733, proteinPer100g:  0.5, carbsPer100g:  0.1, fatPer100g:  81.0, basePortionG: 10),
        FoodItem(name: "Aguacate",                       category: "Grasas",          mainMacro: .fat, caloriesPer100g: 179, proteinPer100g:  2.0, carbsPer100g:  9.0, fatPer100g:  15.0, basePortionG: 100),
        FoodItem(name: "Mayonesa",                       category: "Grasas",          mainMacro: .fat, caloriesPer100g: 710, proteinPer100g:  1.0, carbsPer100g:  1.0, fatPer100g:  78.0, basePortionG: 15),
        FoodItem(name: "Mayonesa ligera",                category: "Grasas",          mainMacro: .fat, caloriesPer100g: 384, proteinPer100g:  1.0, carbsPer100g:  5.0, fatPer100g:  40.0, basePortionG: 15),
        FoodItem(name: "Mayonesa 0%",                    category: "Grasas",          mainMacro: .fat, caloriesPer100g:  21, proteinPer100g:  1.0, carbsPer100g:  2.0, fatPer100g:   1.0, basePortionG: 15),
        FoodItem(name: "Salsa César",                    category: "Grasas",          mainMacro: .fat, caloriesPer100g: 344, proteinPer100g:  3.0, carbsPer100g:  4.0, fatPer100g:  32.0, basePortionG: 15),
        FoodItem(name: "Salsa bechamel",                 category: "Grasas",          mainMacro: .fat, caloriesPer100g: 122, proteinPer100g:  3.0, carbsPer100g:  5.0, fatPer100g:  10.0, basePortionG: 50),
        FoodItem(name: "Crema de cacahuete",             category: "Grasas",          mainMacro: .fat, caloriesPer100g: 610, proteinPer100g: 25.0, carbsPer100g: 20.0, fatPer100g:  50.0, basePortionG: 30),
        FoodItem(name: "Crema de almendra",              category: "Grasas",          mainMacro: .fat, caloriesPer100g: 590, proteinPer100g: 22.0, carbsPer100g: 18.0, fatPer100g:  50.0, basePortionG: 30),
        FoodItem(name: "Crema de avellana",              category: "Grasas",          mainMacro: .fat, caloriesPer100g: 580, proteinPer100g: 13.0, carbsPer100g: 57.0, fatPer100g:  30.0, basePortionG: 20),

        // MARK: Frutos Secos y Semillas

        FoodItem(name: "Almendras",                      category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 613, proteinPer100g: 21.0, carbsPer100g: 22.0, fatPer100g: 49.0, basePortionG: 30),
        FoodItem(name: "Nueces",                         category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 697, proteinPer100g: 15.0, carbsPer100g: 14.0, fatPer100g: 65.0, basePortionG: 30),
        FoodItem(name: "Pistachos",                      category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 625, proteinPer100g: 20.0, carbsPer100g: 28.0, fatPer100g: 45.0, basePortionG: 30),
        FoodItem(name: "Anacardos",                      category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 583, proteinPer100g: 18.0, carbsPer100g: 30.0, fatPer100g: 43.0, basePortionG: 30),
        FoodItem(name: "Cacahuetes",                     category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 614, proteinPer100g: 25.0, carbsPer100g: 16.0, fatPer100g: 50.0, basePortionG: 30),
        FoodItem(name: "Frutos secos mixtos",            category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 610, proteinPer100g: 20.0, carbsPer100g: 20.0, fatPer100g: 50.0, basePortionG: 30),
        FoodItem(name: "Pipas de calabaza",              category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 610, proteinPer100g: 30.0, carbsPer100g: 10.0, fatPer100g: 50.0, basePortionG: 20),
        FoodItem(name: "Semillas de chía",               category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 431, proteinPer100g: 17.0, carbsPer100g: 42.0, fatPer100g: 31.0, fiberPer100g: 34.0, basePortionG: 20),
        FoodItem(name: "Semillas de lino",               category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 446, proteinPer100g: 18.0, carbsPer100g: 29.0, fatPer100g: 42.0, fiberPer100g: 27.0, basePortionG: 20),
        FoodItem(name: "Semillas de cáñamo",             category: "Frutos Secos",    mainMacro: .fat, caloriesPer100g: 613, proteinPer100g: 32.0, carbsPer100g:  9.0, fatPer100g: 45.0, basePortionG: 20),

        // MARK: Embutidos y Fiambres

        FoodItem(name: "Jamón serrano",                  category: "Embutidos",       mainMacro: .protein, caloriesPer100g: 228, proteinPer100g: 30.0, carbsPer100g:  0.0, fatPer100g: 12.0, basePortionG: 50),
        FoodItem(name: "Jamón cocido",                   category: "Embutidos",       mainMacro: .protein, caloriesPer100g: 115, proteinPer100g: 16.0, carbsPer100g:  1.5, fatPer100g:  5.0, basePortionG: 80),
        FoodItem(name: "Pavo en lonchas",                category: "Embutidos",       mainMacro: .protein, caloriesPer100g: 134, proteinPer100g: 29.0, carbsPer100g:  0.0, fatPer100g:  2.0, basePortionG: 80),
        FoodItem(name: "Lomo embuchado",                 category: "Embutidos",       mainMacro: .protein, caloriesPer100g: 384, proteinPer100g: 50.0, carbsPer100g:  1.0, fatPer100g: 20.0, basePortionG: 40),
        FoodItem(name: "Chorizo",                        category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 379, proteinPer100g: 25.0, carbsPer100g:  1.8, fatPer100g: 30.0, basePortionG: 40),
        FoodItem(name: "Salchichas",                     category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 282, proteinPer100g: 12.0, carbsPer100g:  1.5, fatPer100g: 25.0, basePortionG: 80),
        FoodItem(name: "Bacón",                          category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 428, proteinPer100g: 12.0, carbsPer100g:  0.6, fatPer100g: 42.0, basePortionG: 40),
        FoodItem(name: "Fuet",                           category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 422, proteinPer100g: 28.0, carbsPer100g:  1.0, fatPer100g: 34.0, basePortionG: 30),
        FoodItem(name: "Salchichón",                     category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 384, proteinPer100g: 23.0, carbsPer100g:  2.0, fatPer100g: 32.0, basePortionG: 30),
        FoodItem(name: "Mortadela",                      category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 262, proteinPer100g: 12.0, carbsPer100g:  3.0, fatPer100g: 22.0, basePortionG: 50),
        FoodItem(name: "Sobrasada",                      category: "Embutidos",       mainMacro: .fat,     caloriesPer100g: 582, proteinPer100g: 15.9, carbsPer100g:  3.0, fatPer100g: 55.2, basePortionG: 30),
        FoodItem(name: "Chopped",                        category: "Embutidos",       mainMacro: .protein, caloriesPer100g: 261, proteinPer100g: 16.0, carbsPer100g:  2.0, fatPer100g: 21.0, basePortionG: 50),

        // MARK: Salsas y Condimentos

        FoodItem(name: "Ketchup",                        category: "Condimentos",     mainMacro: .carbs, caloriesPer100g: 107, proteinPer100g:  1.3, carbsPer100g: 25.0, fatPer100g:  0.1, basePortionG: 20),
        FoodItem(name: "Ketchup 0%",                     category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  16, proteinPer100g:  0.0, carbsPer100g:  4.0, fatPer100g:  0.0, basePortionG: 20),
        FoodItem(name: "Mostaza",                        category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  94, proteinPer100g:  4.0, carbsPer100g:  6.0, fatPer100g:  6.0, basePortionG: 15),
        FoodItem(name: "Salsa barbacoa",                 category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  96, proteinPer100g:  0.5, carbsPer100g: 23.0, fatPer100g:  0.2, basePortionG: 20),
        FoodItem(name: "Salsa barbacoa 0%",              category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  24, proteinPer100g:  1.0, carbsPer100g:  5.0, fatPer100g:  0.0, basePortionG: 20),
        FoodItem(name: "Salsa de tomate",                category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  30, proteinPer100g:  1.2, carbsPer100g:  6.0, fatPer100g:  0.2, basePortionG: 50),
        FoodItem(name: "Salsa de ajo",                   category: "Condimentos",     mainMacro: .fat,   caloriesPer100g: 114, proteinPer100g:  1.0, carbsPer100g:  5.0, fatPer100g: 10.0, basePortionG: 15),
        FoodItem(name: "Salsa curry",                    category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  89, proteinPer100g:  1.0, carbsPer100g: 10.0, fatPer100g:  5.0, basePortionG: 20),
        FoodItem(name: "Salsa chili dulce",              category: "Condimentos",     mainMacro: .carbs, caloriesPer100g:  83, proteinPer100g:  0.5, carbsPer100g: 20.0, fatPer100g:  0.2, basePortionG: 20),
        FoodItem(name: "Miel",                           category: "Condimentos",     mainMacro: .carbs, caloriesPer100g: 329, proteinPer100g:  0.3, carbsPer100g: 82.0, fatPer100g:  0.0, basePortionG: 15),
        FoodItem(name: "Azúcar",                         category: "Condimentos",     mainMacro: .carbs, caloriesPer100g: 400, proteinPer100g:  0.0, carbsPer100g: 100.0, fatPer100g: 0.0, basePortionG: 10),
        FoodItem(name: "Mermelada",                      category: "Condimentos",     mainMacro: .carbs, caloriesPer100g: 241, proteinPer100g:  0.2, carbsPer100g: 60.0, fatPer100g:  0.0, basePortionG: 20),
        FoodItem(name: "Chocolate negro 70%",            category: "Condimentos",     mainMacro: .fat,   caloriesPer100g: 614, proteinPer100g:  7.8, carbsPer100g: 46.0, fatPer100g: 43.0, basePortionG: 20),

        // MARK: Proteínas en Polvo

        FoodItem(name: "Whey Protein",                   category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 373, proteinPer100g: 73.0, carbsPer100g:  8.8, fatPer100g:  3.8, basePortionG: 30),
        FoodItem(name: "Whey Isolate",                   category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 381, proteinPer100g: 88.0, carbsPer100g:  4.2, fatPer100g:  0.9, basePortionG: 30),
        FoodItem(name: "Caseína",                        category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 379, proteinPer100g: 76.0, carbsPer100g:  7.9, fatPer100g:  0.9, basePortionG: 30),
        FoodItem(name: "Proteína de guisante",           category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 393, proteinPer100g: 70.0, carbsPer100g:  6.7, fatPer100g:  8.3, basePortionG: 30),
        FoodItem(name: "Proteína de arroz",              category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 365, proteinPer100g: 73.3, carbsPer100g:  6.7, fatPer100g:  5.0, basePortionG: 30),
        FoodItem(name: "Proteína vegana",                category: "Proteínas",       mainMacro: .protein, caloriesPer100g: 362, proteinPer100g: 73.3, carbsPer100g: 10.0, fatPer100g:  3.3, basePortionG: 30),

        // MARK: Platos Preparados y Otros

        FoodItem(name: "Tortilla de patata",             category: "Platos",          mainMacro: .carbs, caloriesPer100g: 198, proteinPer100g:  7.0, carbsPer100g: 20.0, fatPer100g: 10.0, basePortionG: 150),
        FoodItem(name: "Pizza",                          category: "Platos",          mainMacro: .carbs, caloriesPer100g: 242, proteinPer100g: 11.0, carbsPer100g: 27.0, fatPer100g: 10.0, basePortionG: 300),
        FoodItem(name: "Pizza proteica",                 category: "Platos",          mainMacro: .protein, caloriesPer100g: 238, proteinPer100g: 20.0, carbsPer100g: 25.0, fatPer100g:  6.0, basePortionG: 300),
        FoodItem(name: "Patatas fritas",                 category: "Platos",          mainMacro: .carbs, caloriesPer100g: 554, proteinPer100g:  6.0, carbsPer100g: 53.0, fatPer100g: 34.0, basePortionG: 100),
        FoodItem(name: "Cocido madrileño",               category: "Platos",          mainMacro: .carbs, caloriesPer100g: 134, proteinPer100g:  8.0, carbsPer100g: 12.0, fatPer100g:  6.0, basePortionG: 300),
        FoodItem(name: "Merluza empanada",               category: "Platos",          mainMacro: .protein, caloriesPer100g: 170, proteinPer100g: 10.3, carbsPer100g: 16.3, fatPer100g:  6.9, basePortionG: 150),
        FoodItem(name: "Lasaña de atún",                 category: "Platos",          mainMacro: .protein, caloriesPer100g: 164, proteinPer100g:  9.6, carbsPer100g: 15.0, fatPer100g:  6.7, basePortionG: 250),
        FoodItem(name: "Lasaña boloñesa",                category: "Platos",          mainMacro: .protein, caloriesPer100g: 161, proteinPer100g:  8.2, carbsPer100g: 16.0, fatPer100g:  6.2, basePortionG: 250),
        FoodItem(name: "Salmorejo",                      category: "Platos",          mainMacro: .carbs, caloriesPer100g:  64, proteinPer100g:  1.0, carbsPer100g:  5.0, fatPer100g:  4.0, basePortionG: 250),
        FoodItem(name: "Gazpacho",                       category: "Platos",          mainMacro: .carbs, caloriesPer100g:  40, proteinPer100g:  1.0, carbsPer100g:  4.0, fatPer100g:  3.0, basePortionG: 250),
        FoodItem(name: "Helado",                         category: "Platos",          mainMacro: .carbs, caloriesPer100g: 202, proteinPer100g:  3.5, carbsPer100g: 23.0, fatPer100g: 10.0, basePortionG: 100),
        FoodItem(name: "Helado proteico",                category: "Platos",          mainMacro: .protein, caloriesPer100g: 132, proteinPer100g:  9.0, carbsPer100g: 15.0, fatPer100g:  4.0, basePortionG: 100),
        FoodItem(name: "Galletas",                       category: "Platos",          mainMacro: .carbs, caloriesPer100g: 496, proteinPer100g:  6.0, carbsPer100g: 70.0, fatPer100g: 20.0, basePortionG: 30),
        FoodItem(name: "Croissant",                      category: "Platos",          mainMacro: .carbs, caloriesPer100g: 413, proteinPer100g:  7.0, carbsPer100g: 45.0, fatPer100g: 25.0, basePortionG: 80),

        // MARK: Bebidas y Lácteos Vegetales

        FoodItem(name: "Leche de soja",                  category: "Bebidas",         mainMacro: .protein, caloriesPer100g:  40, proteinPer100g:  3.3, carbsPer100g:  2.7, fatPer100g:  1.8, basePortionG: 250),
        FoodItem(name: "Leche de almendra",              category: "Bebidas",         mainMacro: .fat,   caloriesPer100g:  28, proteinPer100g:  0.5, carbsPer100g:  0.6, fatPer100g:  2.5, basePortionG: 250),
        FoodItem(name: "Leche de avena",                 category: "Bebidas",         mainMacro: .carbs, caloriesPer100g:  50, proteinPer100g:  1.6, carbsPer100g:  8.2, fatPer100g:  0.7, basePortionG: 250),
        FoodItem(name: "Zumo de naranja",                category: "Bebidas",         mainMacro: .carbs, caloriesPer100g:  45, proteinPer100g:  0.7, carbsPer100g: 10.4, fatPer100g:  0.2, basePortionG: 200),
        FoodItem(name: "Bebida isotónica",               category: "Bebidas",         mainMacro: .carbs, caloriesPer100g:  24, proteinPer100g:  0.0, carbsPer100g:  6.0, fatPer100g:  0.0, basePortionG: 500),
        FoodItem(name: "Café negro",                     category: "Bebidas",         mainMacro: .carbs, caloriesPer100g:   2, proteinPer100g:  0.1, carbsPer100g:  0.0, fatPer100g:  0.0, basePortionG: 200),
    ] }
}

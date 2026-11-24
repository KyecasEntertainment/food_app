class FoodItem {
  final int id;
  final String category;
  final String name;
  final String photo;
  final double price;

  FoodItem({
    required this.id,
    required this.category,
    required this.photo,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'photo': photo,
    'name': name,
    'price': price,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as int,
    category: json['category'] as String? ?? '',
    photo: json['photo'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

final List<FoodItem> products = [
  // Burgers (5 items)
  FoodItem(
    id: 1,
    category: "Burgers",
    photo: "assets/food_images/Burgers/ClassicBurger.jpg",
    name: "Classic Burger",
    price: 149.00,
  ),
  FoodItem(
    id: 2,
    category: "Burgers",
    photo: "assets/food_images/Burgers/DoubleCheeseBurger.jpg",
    name: "Double Cheeseburger",
    price: 189.00,
  ),
  FoodItem(
    id: 3,
    category: "Burgers",
    photo: "assets/food_images/Burgers/BaconBurger.jpg",
    name: "Bacon Burger",
    price: 219.00,
  ),
  FoodItem(
    id: 4,
    category: "Burgers",
    photo: "assets/food_images/Burgers/MushroomBurger.jpg",
    name: "Mushroom Swiss Burger",
    price: 199.00,
  ),
  FoodItem(
    id: 5,
    category: "Burgers",
    photo: "assets/food_images/Burgers/JalapeñoBurger.jpg",
    name: "Spicy Jalapeño Burger",
    price: 169.00,
  ),
  // Pizza (5 items)
  FoodItem(
    id: 6,
    category: "Pizza",
    photo: "assets/food_images/Pizzas/MargheritaPizza.jpg",
    name: "Margherita Pizza",
    price: 289.00,
  ),
  FoodItem(
    id: 7,
    category: "Pizza",
    photo: "assets/food_images/Pizzas/PeperoniPizza.jpg",
    name: "Pepperoni Pizza",
    price: 329.00,
  ),
  FoodItem(
    id: 8,
    category: "Pizza",
    photo: "assets/food_images/Pizzas/SupremePizza.jpg",
    name: "Supreme Pizza",
    price: 379.00,
  ),
  FoodItem(
    id: 9,
    category: "Pizza",
    photo: "assets/food_images/Pizzas/VeggiePizza.jpg",
    name: "Veggie Pizza",
    price: 269.00,
  ),
  FoodItem(
    id: 10,
    category: "Pizza",
    photo: "assets/food_images/Pizzas/BBQPizza.jpg",
    name: "BBQ Chicken Pizza",
    price: 349.00,
  ),
  // Fried Chicken (5 items)
  FoodItem(
    id: 11,
    category: "Fried Chicken",
    photo: "assets/food_images/Chicken/ChickenWSides.jpg",
    name: "Chicken Combo",
    price: 239.00,
  ),
  FoodItem(
    id: 12,
    category: "Fried Chicken",
    photo: "assets/food_images/Chicken/ChickenSpicy.jpg",
    name: "Spicy Fried Chicken",
    price: 219.00,
  ),
  FoodItem(
    id: 13,
    category: "Fried Chicken",
    photo: "assets/food_images/Chicken/ChickenWings.jpg",
    name: "Crispy Chicken Wings",
    price: 179.00,
  ),
  FoodItem(
    id: 14,
    category: "Fried Chicken",
    photo: "assets/food_images/Chicken/ChickenTenders.jpg",
    name: "Chicken Tenders",
    price: 189.00,
  ),
  FoodItem(
    id: 15,
    category: "Fried Chicken",
    photo: "assets/food_images/Chicken/ChickenBucket.jpg",
    name: "Family Chicken Bucket",
    price: 459.00,
  ),
  // Fries (5 items)
  FoodItem(
    id: 16,
    category: "Fries",
    photo: "assets/food_images/Fries/RegularFries.jpg",
    name: "Regular Fries",
    price: 89.00,
  ),
  FoodItem(
    id: 17,
    category: "Fries",
    photo: "assets/food_images/Fries/CheesyFries.jpg",
    name: "Cheese Fries",
    price: 119.00,
  ),
  FoodItem(
    id: 18,
    category: "Fries",
    photo: "assets/food_images/Fries/BaconFries.jpg",
    name: "Bacon Cheese Fries",
    price: 149.00,
  ),
  FoodItem(
    id: 19,
    category: "Fries",
    photo: "assets/food_images/Fries/CajunFries.jpg",
    name: "Cajun Spiced Fries",
    price: 129.00,
  ),
  FoodItem(
    id: 20,
    category: "Fries",
    photo: "assets/food_images/Fries/OverloadFries.jpg",
    name: "Loaded Fries",
    price: 169.00,
  ),
  // Drinks (5 items)
  FoodItem(
    id: 21,
    category: "Drinks",
    photo: "assets/food_images/Drinks/CocaCola.jpg",
    name: "Coca Cola",
    price: 65.00,
  ),
  FoodItem(
    id: 22,
    category: "Drinks",
    photo: "assets/food_images/Drinks/Sprite.jpg",
    name: "Sprite",
    price: 65.00,
  ),
  FoodItem(
    id: 23,
    category: "Drinks",
    photo: "assets/food_images/Drinks/IcedTea.jpg",
    name: "Iced Tea",
    price: 59.00,
  ),
  FoodItem(
    id: 24,
    category: "Drinks",
    photo: "assets/food_images/Drinks/VanillaMilkshake.jpg",
    name: "Vanilla Milkshake",
    price: 129.00,
  ),
  FoodItem(
    id: 25,
    category: "Drinks",
    photo: "assets/food_images/Drinks/OrangeJuice.jpg",
    name: "Fresh Orange Juice",
    price: 99.00,
  ),
];

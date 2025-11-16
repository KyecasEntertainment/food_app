class StoreProducts {
  final int product_id;
  final String product_category;
  final String product_name;
  final String product_image;
  final double product_price;

  StoreProducts({
    required this.product_id,
    required this.product_category,
    required this.product_image,
    required this.product_name,
    required this.product_price,
  });
}

final List<StoreProducts> products = [
  // Burgers (5 items)
  StoreProducts(
    product_id: 1,
    product_category: "Burgers",
    product_image: "assets/food_images/Burgers/ClassicBurger.jpg",
    product_name: "Classic Burger",
    product_price: 5.99,
  ),
  StoreProducts(
    product_id: 2,
    product_category: "Burgers",
    product_image: "assets/food_images/Burgers/DoubleCheeseBurger.jpg",
    product_name: "Double Cheeseburger",
    product_price: 7.49,
  ),
  StoreProducts(
    product_id: 3,
    product_category: "Burgers",
    product_image: "assets/food_images/Burgers/BaconBurger.jpg",
    product_name: "Bacon Burger",
    product_price: 8.99,
  ),
  StoreProducts(
    product_id: 4,
    product_category: "Burgers",
    product_image: "assets/food_images/Burgers/MushroomBurger.jpg",
    product_name: "Mushroom Swiss Burger",
    product_price: 7.99,
  ),
  StoreProducts(
    product_id: 5,
    product_category: "Burgers",
    product_image: "assets/food_images/Burgers/JalapeñoBurger.jpg",
    product_name: "Spicy Jalapeño Burger",
    product_price: 6.99,
  ),
  // Pizza (5 items)
  StoreProducts(
    product_id: 6,
    product_category: "Pizza",
    product_image: "assets/food_images/Pizzas/MargheritaPizza.jpg",
    product_name: "Margherita Pizza",
    product_price: 9.99,
  ),
  StoreProducts(
    product_id: 7,
    product_category: "Pizza",
    product_image: "assets/food_images/Pizzas/PeperoniPizza.jpg",
    product_name: "Pepperoni Pizza",
    product_price: 10.99,
  ),
  StoreProducts(
    product_id: 8,
    product_category: "Pizza",
    product_image: "assets/food_images/Pizzas/SupremePizza.jpg",
    product_name: "Supreme Pizza",
    product_price: 12.99,
  ),
  StoreProducts(
    product_id: 9,
    product_category: "Pizza",
    product_image: "assets/food_images/Pizzas/VeggiePizza.jpg",
    product_name: "Veggie Pizza",
    product_price: 8.99,
  ),
  StoreProducts(
    product_id: 10,
    product_category: "Pizza",
    product_image: "assets/food_images/Pizzas/BBQPizza.jpg",
    product_name: "BBQ Chicken Pizza",
    product_price: 11.99,
  ),
  // Fried Chicken (5 items)
  StoreProducts(
    product_id: 11,
    product_category: "Fried Chicken",
    product_image: "assets/food_images/Chicken/ChickenWSides.jpg",
    product_name: "Chicken Combo",
    product_price: 8.49,
  ),
  StoreProducts(
    product_id: 12,
    product_category: "Fried Chicken",
    product_image: "assets/food_images/Chicken/ChickenSpicy.jpg",
    product_name: "Spicy Fried Chicken",
    product_price: 7.99,
  ),
  StoreProducts(
    product_id: 13,
    product_category: "Fried Chicken",
    product_image: "assets/food_images/Chicken/ChickenWings.jpg",
    product_name: "Crispy Chicken Wings",
    product_price: 5.99,
  ),
  StoreProducts(
    product_id: 14,
    product_category: "Fried Chicken",
    product_image: "assets/food_images/Chicken/ChickenTenders.jpg",
    product_name: "Chicken Tenders",
    product_price: 6.49,
  ),
  StoreProducts(
    product_id: 15,
    product_category: "Fried Chicken",
    product_image: "assets/food_images/Chicken/ChickenBucket.jpg",
    product_name: "Family Chicken Bucket",
    product_price: 15.99,
  ),
  // Fries (5 items)
  StoreProducts(
    product_id: 16,
    product_category: "Fries",
    product_image: "assets/food_images/Fries/RegularFries.jpg",
    product_name: "Regular Fries",
    product_price: 2.49,
  ),
  StoreProducts(
    product_id: 17,
    product_category: "Fries",
    product_image: "assets/food_images/Fries/CheesyFries.jpg",
    product_name: "Cheese Fries",
    product_price: 3.49,
  ),
  StoreProducts(
    product_id: 18,
    product_category: "Fries",
    product_image: "assets/food_images/Fries/BaconFries.jpg",
    product_name: "Bacon Cheese Fries",
    product_price: 4.99,
  ),
  StoreProducts(
    product_id: 19,
    product_category: "Fries",
    product_image: "assets/food_images/Fries/CajunFries.jpg",
    product_name: "Cajun Spiced Fries",
    product_price: 3.99,
  ),
  StoreProducts(
    product_id: 20,
    product_category: "Fries",
    product_image: "assets/food_images/Fries/OverloadFries.jpg",
    product_name: "Loaded Fries",
    product_price: 5.49,
  ),
  // Drinks (5 items)
  StoreProducts(
    product_id: 21,
    product_category: "Drinks",
    product_image: "assets/food_images/Drinks/CocaCola.jpg",
    product_name: "Coca Cola",
    product_price: 2.50,
  ),
  StoreProducts(
    product_id: 22,
    product_category: "Drinks",
    product_image: "assets/food_images/Drinks/Sprite.jpg",
    product_name: "Sprite",
    product_price: 2.50,
  ),
  StoreProducts(
    product_id: 23,
    product_category: "Drinks",
    product_image: "assets/food_images/Drinks/IcedTea.jpg",
    product_name: "Iced Tea",
    product_price: 2.49,
  ),
  StoreProducts(
    product_id: 24,
    product_category: "Drinks",
    product_image: "assets/food_images/Drinks/VanillaMilkshake.jpg",
    product_name: "Vanilla Milkshake",
    product_price: 3.99,
  ),
  StoreProducts(
    product_id: 25,
    product_category: "Drinks",
    product_image: "assets/food_images/Drinks/OrangeJuice.jpg",
    product_name: "Fresh Orange Juice",
    product_price: 3.49,
  ),
];

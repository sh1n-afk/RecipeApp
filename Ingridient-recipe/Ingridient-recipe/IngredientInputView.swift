import SwiftUI
import Foundation

struct IngredientInputView: View {
    @State private var ingredient: String = ""
    @State private var ingredients: [String] = []
    @State private var recipes: [Recipe] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Ingredients")) {
                    TextField("Ingredient", text: $ingredient)
                }

                Button(action: {
                    guard !ingredient.isEmpty else { return }
                    ingredients.append(ingredient)
                    ingredient = ""
                    fetchRecipes()
                }) {
                    Text("Add Ingredient")
                }

                Section(header: Text("Entered Ingredients")) {
                    List(ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                }

                Section(header: Text("Recipes")) {
                    if recipes.isEmpty {
                        Text("No recipes found.")
                    } else {
                        List(recipes, id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                HStack {
                                            if let imageURL = URL(string: "https://spoonacular.com/recipeImages/\(recipe.id)-636x393.jpg"),
                                               let imageData = try? Data(contentsOf: imageURL),
                                               let uiImage = UIImage(data: imageData) {
                                               Image(uiImage: uiImage)
                                                   .resizable()
                                                   .scaledToFill()
                                                   .frame(width: 50, height: 50)
                                                   .clipped()
                                                   .cornerRadius(10)
                                            }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Ingredients")
        }
    }

    func fetchRecipes() {
        let apiKey = "fa46be1f70464e32851d15afb57fd92b"
        let ingredientsQuery = ingredients.joined(separator: ",")
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientsQuery)&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching recipes: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let fetchedRecipes = try JSONDecoder().decode([Recipe].self, from: data)
                DispatchQueue.main.async {
                    self.recipes = fetchedRecipes
                }
            } catch {
                print("Error decoding recipes: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct IngredientInputView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientInputView()
    }
}

import SwiftUI

struct RecipeDetailsView: View {
    let recipe: Recipe
    @State private var recipeInformation: RecipeInformation?
    @State private var recipeImage: UIImage?

    var body: some View {
        ScrollView {
            VStack {
                if let recipeImage = recipeImage {
                    Image(uiImage: recipeImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }

                Text(recipe.title)
                    .font(.largeTitle)
                    .padding()

                if let recipeInformation = recipeInformation {
                    VStack {
                        Text("Instructions:")
                            .font(.headline)
                            .padding()

                        ScrollView {
                            Text(recipeInformation.instructions)
                                .padding()
                        }
                    }
                } else {
                    Text("Fetching recipe details...")
                        .padding()
                        .onAppear {
                            self.fetchRecipeInformation()
                            self.fetchRecipeImage()
                        }
                }
            }
            .navigationBarTitle("Recipe Details")
        }
    }
    func fetchRecipeImage() {
        let apiKey = "fa46be1f70464e32851d15afb57fd92b"
        let urlString = "https://spoonacular.com/recipeImages/\(recipe.id)-636x393.jpg"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching recipe image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.recipeImage = image
                }
            }
        }.resume()
    }

    func fetchRecipeInformation() {
        let apiKey = "fa46be1f70464e32851d15afb57fd92b"
        let urlString = "https://api.spoonacular.com/recipes/\(recipe.id)/information?apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching recipe information: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let fetchedRecipeInformation = try JSONDecoder().decode(RecipeInformation.self, from: data)
                DispatchQueue.main.async {
                    self.recipeInformation = fetchedRecipeInformation
                }
            } catch {
                print("Error decoding recipe information: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct RecipeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailsView(recipe: Recipe(id: 1, title: "Sample Recipe", image: ""))
    }
}

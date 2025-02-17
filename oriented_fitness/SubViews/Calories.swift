import SwiftUI
import CoreData

struct CaloriesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodDayRecord.date, ascending: false)],
        animation: .default)
    private var foodDayRecords: FetchedResults<FoodDayRecord>

    var body: some View {
        NavigationView {
            List {
                ForEach(foodDayRecords) { record in
                    NavigationLink {
                        FoodItemsView(foodDayRecord: record)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(record.date ?? Date(), formatter: dateFormatter)")
                            Text("Total Calories: \(record.totalCalories, specifier: "%.0f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Protein: \(record.totalProtein, specifier: "%.0f")g, Carbs: \(record.totalCarbs, specifier: "%.0f")g, Fat: \(record.totalFats, specifier: "%.0f")g")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select a day")
        }
    }

    private func addItem() {
        withAnimation {
            let newRecord = FoodDayRecord(context: viewContext)
            newRecord.date = Date()
            newRecord.totalCalories = 0
            newRecord.totalFats = 0
            newRecord.totalCarbs = 0
            newRecord.totalProtein = 0

            newRecord.recalculateTotals()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { foodDayRecords[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct FoodItemsView: View {
    @ObservedObject var foodDayRecord: FoodDayRecord
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddFoodItem = false
    @State private var date: Date

    init(foodDayRecord: FoodDayRecord) {
        self.foodDayRecord = foodDayRecord
        _date = State(initialValue: foodDayRecord.date ?? Date())
    }

    var body: some View {
        VStack {
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .onChange(of: date) { _ , newValue in
                    foodDayRecord.date = newValue
                    saveContext()
                }

            List {
                ForEach(foodDayRecord.foodItemsArray, id: \.self) { foodItem in
                    FoodItemRow(foodItem: foodItem, foodDayRecord: foodDayRecord)
                }
                .onDelete(perform: deleteFoodItems)
            }
        }
        .navigationTitle("Food Items")
        .toolbar {
            Button(action: { showingAddFoodItem = true }) {
                Label("Add Food Item", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddFoodItem) {
            AddFoodItemView(foodDayRecord: foodDayRecord)
        }
    }

    private func deleteFoodItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { foodDayRecord.foodItemsArray[$0] }.forEach(viewContext.delete)
            foodDayRecord.recalculateTotals()
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct FoodItemRow: View {
    @ObservedObject var foodItem: FoodItem
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var foodDayRecord: FoodDayRecord

    var body: some View {
        VStack {
            TextField("Food Name", text: Binding(
                get: { foodItem.name ?? "" },
                set: { foodItem.name = $0 }
            ))
            .font(.headline)
            
            HStack {
                Text("Calories:")
                TextField("Calories", value: Binding<Double>(
                    get: { foodItem.calories },
                    set: {
                         foodItem.calories = $0
                         foodDayRecord.recalculateTotals()
                         saveContext()
                    }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("Protein:")
                TextField("Protein", value: Binding<Double>(
                    get: { foodItem.protein },
                    set: {
                         foodItem.protein = $0
                         foodDayRecord.recalculateTotals()
                         saveContext()
                    }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                Text("g")
            }
            
            HStack {
                Text("Carbs:")
                TextField("Carbs", value: Binding<Double>(
                    get: { foodItem.carbs },
                    set: {
                         foodItem.carbs = $0
                         foodDayRecord.recalculateTotals()
                         saveContext()
                    }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                Text("g")
            }
            
            HStack {
                Text("Fats:")
                TextField("Fats", value: Binding<Double>(
                    get: { foodItem.fats },
                    set: {
                         foodItem.fats = $0
                         foodDayRecord.recalculateTotals()
                         saveContext()
                    }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                Text("g")
            }
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddFoodItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var foodDayRecord: FoodDayRecord
    
    @State private var name = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Food Name", text: $name)
                TextField("Calories", text: $calories)
                    .keyboardType(.decimalPad)
                TextField("Protein (g)", text: $protein)
                    .keyboardType(.decimalPad)
                TextField("Carbs (g)", text: $carbs)
                    .keyboardType(.decimalPad)
                TextField("Fats (g)", text: $fats)
            }
            .navigationTitle("Add Food Item")
            .toolbar {
                Button("Save") {
                    saveFood()
                }
            }
        }
    }

    private func saveFood() {
        withAnimation {
            let newItem = FoodItem(context: viewContext)
            newItem.name = name
            newItem.calories = Double(calories) ?? 0
            newItem.protein = Double(protein) ?? 0
            newItem.carbs = Double(carbs) ?? 0
            newItem.fats = Double(fats) ?? 0
            foodDayRecord.addToFoodItems(newItem)

            foodDayRecord.recalculateTotals()

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

extension FoodDayRecord {
    var foodItemsArray: [FoodItem] {
        let set = foodItems as? Set<FoodItem> ?? []
        return set.sorted { $0.name ?? "" < $1.name ?? "" }
    }

    func recalculateTotals() {
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFats: Double = 0

        for item in foodItemsArray {
            totalCalories += item.calories
            totalProtein += item.protein
            totalCarbs += item.carbs
            totalFats += item.fats
        }

        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFats = totalFats
    }
}

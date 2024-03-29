//
//  ContentView.swift
//  PerfectVolume
//
//  Created by Joseph Schaubroeck on 7/28/22.
//

import SwiftUI
import CoreData

struct MainMenuView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.setsWorked)]) var muscleGroups : FetchedResults<MuscleGroupEntity>
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var notes : FetchedResults<NoteEntity>
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    let secondarySystem : Color = Color(UIColor.secondarySystemBackground)
    
    @State var selectedIndex : Int = 0
    let tabBarImageNames = ["rectangle.3.group.fill", "square.and.pencil"]
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    @State var showTutorial : Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                
                Color(.white).ignoresSafeArea()
                
                VStack {
                    switch selectedIndex {
                    case 0:

                        List {
                            ForEach(muscleGroups) { muscle in
                                Section {
                                    NavigationLink(destination: EditMuscleGroupView(muscle: muscle)) {
                                        HStack {
                                            Text(muscle.name)
                                            Spacer()
                                            FractionText(numerator: Int(muscle.setsWorked), denominator: Int(muscle.maxTargetSets))
                                        }
                                    }
                                    
                                }
                                .listRowBackground(muscle.rowColor)
                                
                            }
                            .onDelete(perform: deleteMuscle)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .environment(\.horizontalSizeClass, .regular)
                        Spacer()
                        
                        NavigationLink(destination: CreateMuscleGroupView()) {
                            Image(systemName: "plus.app.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color("Mint Green"))
                                .padding()
                        }
                        .toolbar() {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button {
                                    showTutorial.toggle()
                                } label: {
                                    Image(systemName: "questionmark.circle").font(.system(size: 20)).padding().foregroundColor(Color("Mint Green"))
                                }

                            }
                        }
                        .navigationTitle("Muscle Groups")
                        
                    case 1:
                        List {
                            ForEach(notes) { note in
                                NavigationLink(destination: EditNoteView(note: note)) {
                                    HStack {
                                        Text(note.title ?? "")
                                        Spacer()
                                        Text(dateFormatter.string(from: note.date ?? Date())).padding(.trailing, 10.0)
                                    }
                                }
                                .listRowBackground(secondarySystem)
                            }
                            .onDelete(perform: deleteNote)
                        }
                        Spacer()
                        NavigationLink(destination: CreateNoteView()) {
                            ZStack {
                                Image(systemName: "square.fill").font(.system(size: 40))
                                    .foregroundColor(Color("Mint Green"))
                                Image(systemName: "pencil").font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)

                            }
                                .padding()
                        }
                        .navigationBarTitle("Workout Notes")
                    default:
                        NavigationView {
                            Text("Error")
                        }
                    }
                    
                    Spacer()
                    HStack {
                        ForEach(0..<2) { num in
                            Button(action: {
                                selectedIndex = num
                            }, label: {
                                Spacer()
                                Image(systemName: tabBarImageNames[num])
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(selectedIndex == num ? Color(.black) : .init(white: 0.75))
                                Spacer()
                            })
                            
                        }
                    }
                }
                .fullScreenCover(isPresented: $showTutorial) {
                    Text("Test")
                }
                
                
            }
            
            
        }
        .onAppear {
            decrementAfterSevenDays()
        }
        .preferredColorScheme(ColorScheme.light)
        // this will turn on when help button is pressed
//        .overlay(MainMenuOverlayView)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    private func deleteMuscle(offsets: IndexSet) {
        withAnimation {
            offsets.map { muscleGroups[$0] }.forEach(managedObjContext.delete)
            DataController().save(context: managedObjContext)
        }
    }
    
    private func decrementAfterSevenDays() {
        // create a date that is one week before the current date
        let today = Date()
        let weekAgo: Date = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? Date()
        
        // go through each note
        for note in notes {
            
            // if the note was for a date from more than 7 days ago
            // decrement the muscle groups for each exercise
            if note.date! < weekAgo && note.timerOn {
                for noteExercise in note.exercises! {
                    (noteExercise as AnyObject).muscleGroup?.setsWorked -= (noteExercise as AnyObject).numSets
                }
                
                // set bool to false so this doesn't repeat
                note.timerOn = false
            }
        }
        DataController().save(context: managedObjContext)
    }
    private func deleteNote(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(managedObjContext.delete)
            DataController().save(context: managedObjContext)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

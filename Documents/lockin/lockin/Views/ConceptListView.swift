import SwiftUI

struct ConceptListView: View {
    @StateObject private var viewModel = ConceptListViewModel()
    @State private var showingAddConcept = false
    @State private var showingStudySession = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Due for Review")) {
                    ForEach(viewModel.getDueConcepts(), id: \.id) { concept in
                        ConceptRow(concept: concept, viewModel: viewModel)
                    }
                }
                
                Section(header: Text("All Concepts")) {
                    ForEach(viewModel.concepts, id: \.id) { concept in
                        ConceptRow(concept: concept, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Study Concepts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddConcept = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStudySession = true }) {
                        Image(systemName: "book.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddConcept) {
                AddConceptView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStudySession) {
                StudySessionView(viewModel: viewModel)
            }
        }
    }
}

struct ConceptRow: View {
    let concept: Concept
    @ObservedObject var viewModel: ConceptListViewModel
    @State private var showingReview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(concept.name ?? "")
                    .font(.headline)
                Spacer()
                MasteryIndicator(level: viewModel.getMasteryLevel(for: concept))
            }
            
            Text(concept.content ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let tags = concept.tags as? [String], !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingReview = true
        }
        .sheet(isPresented: $showingReview) {
            ReviewView(concept: concept, viewModel: viewModel)
        }
    }
}

struct MasteryIndicator: View {
    let level: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: level)
                .stroke(levelColor, lineWidth: 4)
                .rotationEffect(.degrees(-90))
            Text("\(Int(level * 100))%")
                .font(.caption2)
                .bold()
        }
        .frame(width: 30, height: 30)
    }
    
    var levelColor: Color {
        switch level {
        case 0..<0.3: return .red
        case 0.3..<0.7: return .orange
        default: return .green
        }
    }
}

struct AddConceptView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConceptListViewModel
    
    @State private var name = ""
    @State private var content = ""
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Concept Details")) {
                    TextField("Name", text: $name)
                    TextEditor(text: $content)
                        .frame(height: 100)
                }
                
                Section(header: Text("Tags (comma-separated)")) {
                    TextField("Tags", text: $tags)
                }
            }
            .navigationTitle("New Concept")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let tagArray = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                    viewModel.createConcept(name: name, content: content, tags: tagArray)
                    dismiss()
                }
                .disabled(name.isEmpty || content.isEmpty)
            )
        }
    }
}

struct ReviewView: View {
    let concept: Concept
    @ObservedObject var viewModel: ConceptListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(concept.name ?? "")
                    .font(.title)
                    .padding()
                
                Text(concept.content ?? "")
                    .font(.body)
                    .padding()
                
                Spacer()
                
                Text("How well did you recall this concept?")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    ForEach(1...4, id: \.self) { grade in
                        Button(action: {
                            viewModel.recordReview(for: concept, recallGrade: Int16(grade))
                            dismiss()
                        }) {
                            Text("\(grade)")
                                .font(.title2)
                                .frame(width: 60, height: 60)
                                .background(gradeColor(grade))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Skip") { dismiss() })
        }
    }
    
    func gradeColor(_ grade: Int) -> Color {
        switch grade {
        case 1: return .red
        case 2: return .orange
        case 3: return .blue
        case 4: return .green
        default: return .gray
        }
    }
}

struct StudySessionView: View {
    @ObservedObject var viewModel: ConceptListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.currentSession == nil {
                    Text("Start a study session")
                        .font(.title)
                        .padding()
                    
                    Button("Begin Session") {
                        viewModel.startStudySession(technique: "Spaced Repetition")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Current Session")
                        .font(.title)
                        .padding()
                    
                    List(viewModel.getDueConcepts(), id: \.id) { concept in
                        ConceptRow(concept: concept, viewModel: viewModel)
                    }
                    
                    Button("End Session") {
                        viewModel.endStudySession()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
}

#Preview {
    ConceptListView()
} 
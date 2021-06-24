// 
// ProjectView.swift of Portfolio.
// Created by JaimeAlmanza on 27/10/20.
//
// 


import SwiftUI

struct ProjectView: View {
	static let openTag: String? = "Open"
	static let closedTag: String? = "Closed"
	
	@EnvironmentObject var dataController: DataController
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@State private var showingSortOrder = false
	@State private var sortOrder = Item.SortOrder.optimized
	
	let showClosedProjects: Bool
	let projects: FetchRequest<Project>
	
	init(showClosedProjects: Bool) {
		self.showClosedProjects = showClosedProjects
		
		projects = FetchRequest<Project>(entity: Project.entity(),
																		 sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)],
																		 predicate: NSPredicate(format: "closed = %d", showClosedProjects))
	}
	
	var projectsList: some View {
		List {
			ForEach(projects.wrappedValue) { project in
				Section(header: ProjectHeaderView(project: project)) {
					ForEach(project.projectItems(using: sortOrder)) { item in
						ItemRowView(project: project, item: item)
					}
					.onDelete { offsets in
						delete(offsets, from: project)
					}
					
					if showClosedProjects == false {
						Button {
							addItem(to: project)
						} label: {
							Label("Add New Item", systemImage: "plus")
						}
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
	}
	
	var addProjectToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			if showClosedProjects == false {
				Button(action: addProject) {
					// This is a hack. We can't do this for macOS
					// We're just attempting to overide the shipping bug in iOS and mac Catalyst
					// In which voice over ignores accesibility hints or labels for this button in the toolbar.
					if UIAccessibility.isVoiceOverRunning {
						Text("Add Project")
					} else {
						Label("Add Project", systemImage: "plus")
					}
				}
			}
		}
	}
	
	var sortOrderToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				showingSortOrder.toggle()
			} label: {
				Label("Sort", systemImage: "arrow.up.arrow.down")
			}
		}
	}
	
	var body: some View {
		NavigationView {
			Group {
				if projects.wrappedValue.isEmpty {
					Text("There's nothing here right now")
						.foregroundColor(.secondary)
				} else {
					projectsList
				}
			}
			.navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				addProjectToolbarItem
				sortOrderToolbarItem
			}
			.actionSheet(isPresented: $showingSortOrder) {
				ActionSheet(title: Text("Sort items"), message: nil, buttons: [
					.default(Text("Optimized")) { sortOrder = .optimized },
					.default(Text("Creation Date")) { sortOrder = .creationDate },
					.default(Text("Title")) { sortOrder = .title }
				])
			}
			
			SelectSomethingView()
		}
	}
	
	func addProject() {
		withAnimation {
			let project = Project(context: managedObjectContext)
			project.closed = false
			project.creationDate = Date()
			dataController.save()
		}
	}
	
	func addItem(to project: Project) {
		withAnimation {
			let item = Item(context: managedObjectContext)
			item.project = project
			item.creationDate = Date()
			dataController.save()
		}
	}
	
	func delete(_ offsets: IndexSet, from project: Project) {
		let allItems = project.projectItems(using: sortOrder)
		
		for offset in offsets {
			let item = allItems[offset]
			dataController.delete(item)
		}
		dataController.save()
	}
}

struct ProjectView_Previews: PreviewProvider {
	static var dataController = DataController.preview
	
	static var previews: some View {
		ProjectView(showClosedProjects: false)
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
	}
}

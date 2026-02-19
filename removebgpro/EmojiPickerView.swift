import SwiftUI

struct EmojiPickerView: View {
    let onSelected: (String, StickerType, Color) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: PickerTab = .emoji
    @State private var selectedCategoryIndex: Int = 0
    
    enum PickerTab: String, CaseIterable {
        case emoji = "Emoji"
        case giphy = "GIPHY"
    }
    
    // Data Models
    struct Category: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let items: [String]
        let type: StickerType
    }
    
    // --- EMOJI DATA ---
    private let emojiCategories: [Category] = [
        Category(name: "Smileys", icon: "face.smiling", items: [
            "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "🥲", "☺️", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗",
            "😙", "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕",
            "🙁", "☹️", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨", "😰"
        ], type: .emoji),
        Category(name: "Gestures", icon: "hand.thumbsup", items: [
             "👋", "🤚", "🖐", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍",
             "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "💪", "🦾", "🦵", "🦿", "🦶", "👂", "🦻", "👃", "🧠"
        ], type: .emoji),
        Category(name: "Nature", icon: "leaf", items: [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆",
            "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🦟", "🦗", "🕷", "🕸", "🦂", "🐢", "🐍"
        ], type: .emoji),
        Category(name: "Objects", icon: "lightbulb", items: [
            "💡", "🔦", "🕯", "🔌", "🪔", "⏳", "⌛️", "💸", "💵", "💎", "⚖️", "🪜", "🧰", "🪛", "🔧", "🔨", "⚒️", "⛏️", "🪚", "🔩",
            "⚙️", "🪤", "🧱", "⛓️", "🧲", "🔫", "💣", "🧨", "🪓", "🔪", "🗡", "⚔️", "🛡", "🚬", "⚰️", "🪦", "⚱️", "🏺", "🔮", "📿"
        ], type: .emoji),
         Category(name: "Hearts", icon: "heart", items: [
            "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "❤️‍🔥", "❤️‍🩹", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝"
        ], type: .emoji)
    ]
    
    var currentCategories: [Category] {
        emojiCategories
    }
    
    let columns = [GridItem(.adaptive(minimum: 45))]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Tabs
            HStack {
                ForEach(PickerTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation { selectedTab = tab }
                        selectedCategoryIndex = 0
                    }) {
                        VStack(spacing: 6) {
                            Text(tab.rawValue)
                                .font(.headline)
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            
                            // Indicator line
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "tabLine", in: namespace)
                            } else {
                                Rectangle().fill(Color.clear).frame(height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
            .background(.thinMaterial)
            
            // Main Grid
            if selectedTab == .giphy {
                GiphyPickerView(onSelected: { url in
                    onSelected(url, .giphy, .clear)
                })
            } else {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Array(currentCategories.enumerated()), id: \.offset) { index, category in
                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .id(index) // For scrolling
                                    
                                    LazyVGrid(columns: columns, spacing: 15) {
                                        ForEach(category.items, id: \.self) { item in
                                            Button(action: {
                                                // Handle Selection
                                                onSelected(item, .emoji, .clear)
                                            }) {
                                                Text(item)
                                                    .font(.system(size: 35))
                                            }
                                            .frame(width: 50, height: 50)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        .onChange(of: selectedCategoryIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .top)
                            }
                        }
                    }
                }
            }
            
            // Bottom Category Bar
            if selectedTab != .giphy {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(currentCategories.enumerated()), id: \.offset) { index, category in
                            Button(action: {
                                selectedCategoryIndex = index
                            }) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedCategoryIndex == index ? .blue : .gray)
                                    .padding(8)
                                    .background(selectedCategoryIndex == index ? Color.blue.opacity(0.1) : Color.clear)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.ultraThinMaterial)
            }
        }
        .background(Color("BackgroundColor")) // Use system or app background
    }
    
    @Namespace private var namespace
}

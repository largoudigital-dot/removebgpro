import SwiftUI

struct EmojiPickerView: View {
    let onSelected: (String, StickerType, Color) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: PickerTab = .emoji
    @State private var selectedCategoryIndex: Int = 0
    
    enum PickerTab: String, CaseIterable {
        case emoji = "Emoji"
        case sticker = "Sticker"
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
    
    // --- STICKER DATA (Local Assets) ---
    private let stickerCategories: [Category] = [
        Category(name: "Trending", icon: "flame.fill", items: [
            "sticker_cool_text", "sticker_wow_bubble", "sticker_fire_flame", "sticker_omg_text", "sticker_100_score"
        ], type: .imageAsset),
        Category(name: "Love", icon: "heart.fill", items: [
            "sticker_pixel_heart"
        ], type: .imageAsset),
        // Add more local asset names here as you add them to Assets.xcassets
    ]
    
    var currentCategories: [Category] {
        selectedTab == .emoji ? emojiCategories : stickerCategories
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
                                            if category.type == .emoji {
                                                onSelected(item, .emoji, .clear) // Color ignored for emoji
                                            } else if category.type == .imageAsset {
                                                onSelected(item, .imageAsset, .clear)
                                            } else {
                                                onSelected(item, .systemImage, .white) // Default white for stickers
                                            }
                                        }) {
                                            if category.type == .emoji {
                                                Text(item)
                                                    .font(.system(size: 35))
                                            } else if category.type == .imageAsset {
                                                Image(item)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } else {
                                                Image(systemName: item)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.primary)
                                            }
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
            
            // Bottom Category Bar
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
        .background(Color("BackgroundColor")) // Use system or app background
    }
    
    @Namespace private var namespace
}

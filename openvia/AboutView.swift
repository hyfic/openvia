import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL
    @State private var isHoveringWeb = false
    @State private var isHoveringGit = false
    @State private var iconScale: CGFloat = 0.9
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        VStack(spacing: 28) {
            // App Icon with glow and scale animation
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 110, height: 110)
                    .blur(radius: 15)
                    .scaleEffect(iconScale)
                
                if let appIcon = NSImage(named: NSImage.Name("AppIcon")) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                } else {
                    Image(systemName: "link.circle.fill")
                        .resizable()
                        .frame(width: 88, height: 88)
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
            .scaleEffect(iconScale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)) {
                    iconScale = 1.0
                }
            }
            
            VStack(spacing: 8) {
                Text("OpenVia")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.primary, .primary.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                
                Text(appVersion)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text("Route every link to the right browser.")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
                .frame(width: 240)
                .opacity(0.6)
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button(action: {
                        openURL(URL(string: "https://openvia.hyfic.org")!)
                    }) {
                        Label("Website", systemImage: "globe")
                            .font(.system(.callout, weight: .semibold))
                            .frame(width: 110)
                    }
                    .buttonStyle(ModernLinkButtonStyle(isHovering: isHoveringWeb, tint: .blue))
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHoveringWeb = hovering
                        }
                    }
                    
                    Button(action: {
                        openURL(URL(string: "https://github.com/hyfic/openvia")!)
                    }) {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.system(.callout, weight: .semibold))
                            .frame(width: 110)
                    }
                    .buttonStyle(ModernLinkButtonStyle(isHovering: isHoveringGit, tint: .primary))
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHoveringGit = hovering
                        }
                    }
                }
                
                Text("Created with ♥ for macOS")
                    .font(.system(.caption, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Custom Button Style for the links
struct ModernLinkButtonStyle: ButtonStyle {
    var isHovering: Bool
    var tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovering ? tint.opacity(0.15) : Color.secondary.opacity(0.08))
            )
            .foregroundColor(isHovering ? tint : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isHovering ? tint.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovering ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
    }
}

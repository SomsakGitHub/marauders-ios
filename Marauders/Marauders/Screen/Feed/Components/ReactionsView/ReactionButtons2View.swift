import SwiftUI

struct ReactionButtons2View: View {
    var body: some View {
        VStack(spacing: 24) {
            Button {
                
            } label: {
                Image(uiImage: .add)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                    )
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "suit.heart.fill")
                        .font(.title)
                    
                    Text("4K")
                }
                .foregroundStyle(.white)
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "message.fill")
                        .font(.title)
                    
                    Text("20")
                }
                .foregroundStyle(.white)
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.title)
                    
                    Text("Share")
                }
                .foregroundStyle(.white)
            }
        }
        .padding()
    }
}

#Preview {
    ReactionButtons2View()
        .preferredColorScheme(.dark)
}

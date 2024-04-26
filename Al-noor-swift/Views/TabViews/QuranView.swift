//
//  QuranView.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import SwiftUI
import AVKit
import Combine

struct QuranView: View {
    @ObservedObject var dataSurah = ApiServices()
    
    
    var body: some View {
        NavigationView{
            if #available(iOS 15.0, *){
            List{
                
                    ForEach(dataSurah.surahData){
                        
                        surah in
                        Section{
                        NavigationLink(destination : SurahDetail(number: surah.number,title: surah.englishName)){
                            HStack(spacing : 14){

                                    Text("\(surah.number)")
                                        .foregroundColor(Color.primary)
                                        .frame(width : 45, height: 45)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment : .leading, spacing: 4){
                                    Text("\(surah.name)")
                                        .font(.headline)
                                    Text("Surah \(surah.englishName)・\(surah.revelationType)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    }
                    .padding([.leading, .trailing], 15)
                    if (dataSurah.isLoading){
                        VStack{
                            Indicator()
                            Text("Loading...")
                        }
                        .shadow(color: Color.secondary.opacity(0.3), radius: 20)
                    }
                
            }
            .navigationBarTitle("Qur'an")
            .environment(\.defaultMinListRowHeight, 110)
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            }else{
                
                List{

                        ForEach(dataSurah.surahData){
                            surah in
                            Section{
                            NavigationLink(destination : SurahDetail(number: surah.number,title: surah.englishName)){
                                HStack(spacing : 14){
                                         Text("\(surah.number)")
                                             .foregroundColor(Color.primary)
                                             .frame(width : 45, height: 45)
                                             .clipShape(RoundedRectangle(cornerRadius: 10))
                                     
                                    VStack(alignment : .leading, spacing: 4){
                                        Text("\(surah.name)")
                                            .font(.headline)
                                        Text("Surah \(surah.englishName)・\(surah.revelationType)")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        }
                        .padding([.leading, .trailing], 15)
                        if (dataSurah.isLoading){
                            VStack{
                                Indicator()
                                Text("Loading...")
                            }
                            .shadow(color: Color.secondary.opacity(0.3), radius: 20)
                        }
                    
                }
            
            }
        }
        .offset(y: -60)
        .padding(.bottom, -20)
        .padding(.top, 26)
        
    }
}


struct QuranView_Previews: PreviewProvider {
    static var previews: some View {
        QuranView()
    }
}

class SoundManager : ObservableObject{
    @Published var audioPlayer : AVPlayer?
    @Published var isPlaying : Bool = false
    private var currentIndex = 0
    @Published var currentSurahIndex: Int?  // Track current surah index
       private var currentAsset: AVAsset?
       private var currentTime: CMTime = .zero //
    
    func playAudioMany(urls: [String]) {
        guard !urls.isEmpty else { return }

        var playerItems: [AVPlayerItem] = []
        for urlString in urls {
            if let audioURL = URL(string: urlString) {
                let playerItem = AVPlayerItem(url: audioURL)
                playerItems.append(playerItem)
            }
        }
        
        audioPlayer = AVQueuePlayer(items: playerItems)
        audioPlayer?.play()
        isPlaying = true
        currentSurahIndex = 0  // Start with the first surah
    }
    
    

    func pauseAudio() {
            guard let player = audioPlayer else { return }
            player.pause()
            isPlaying = false
            if let currentItem = player.currentItem {
                currentTime = currentItem.currentTime() // Store the current playback tim
            }
        currentSurahIndex = nil
        }
    
   
    
    func playAudio(sound : String){
           guard !sound.isEmpty else { return }
           
           if let urlAudio = URL(string: sound) {
               self.audioPlayer = AVPlayer(url: urlAudio)
               self.audioPlayer?.play()
               self.isPlaying = true
               
               NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
                   guard let self = self else { return }
                   self.currentIndex += 1
                   
                   self.isPlaying = false
               }
           }
       }
       
   
    
}



struct SurahDetail : View{
    var number : Int
    var title : String
    @State var playButtonId : Int = 0
    @ObservedObject var surahFetch = SurahDetailServices()
    @ObservedObject private var soundManager = SoundManager()
    @State private var currentlyPlayingIndex: Int?
    
    @State var currentTime : TimeInterval = 0.0
   
        @State var isPlayingAll : Bool = false
        @State var currentSurahIndex : Int = 0
        @State var totalSurahCount : Int = 0
    @State var audioPlayer: AVQueuePlayer?
    @State var player: AVAudioPlayer?
      @State var isPlaying: Bool = false
    
    
    
    var body: some View{
        ZStack{
            NavigationView {
            VStack{
                ScrollView(showsIndicators : false){
                    
                    ForEach(surahFetch.surahDetail.indices, id: \.self) { index in
                                           let data = surahFetch.surahDetail[index]
                        VStack{
                            VStack(alignment : .trailing){
                                HStack{
                                    Spacer()
                                    Text("\(data.text)")
                                        .multilineTextAlignment(.trailing)
                                        .background(
                                                                Circle()
                                                                    .fill(Color.yellow)
                                                                    .frame(width: 10, height: 10)
                                                                    .opacity(isSurahPlaying(index) ? 1 : 0)
                                                                    .padding(.trailing, 20) // Adjust as needed
                                                            )
                                    
                                }
                                
                                Button(action : {
                    
                                    
                                    if (soundManager.isPlaying == true){
                                        soundManager.pauseAudio()
                                        
                                        if (playButtonId != data.id){
                                            soundManager.playAudio(sound: data.audio)
                                            self.playButtonId = data.id
                                        }
                                        
                                    }else{
                                        soundManager.playAudio(sound: data.audio)
                                        self.playButtonId = data.id
                                    }
                                    
                                    
                                }){
                                    
                                    if (data.id == playButtonId &&
                                        soundManager.isPlaying == true){
                                        HStack{
                                            Image(systemName: "pause.fill")
                                            Text("Audio")
                                        }
                                        .padding([.top, .bottom], 5)
                                        .padding([.leading, .trailing], 14)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }else{
                                        HStack{
                                            Image(systemName: "play.fill")
                                            Text("Audio")
                                        }
                                        .padding([.top, .bottom], 5)
                                        .padding([.leading, .trailing], 14)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }
                                    
                                    
                                }
                                    
                                }
                            
                            }
                        }
                   
                        .padding(.bottom, 80)
                    }
                HStack {
                    Button(action: playPrevious) {
                        Image(systemName: "backward.fill")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .disabled(playButtonId == 0) // Disable button when at first surah
                    
                    Spacer()
                    
                    Button(action: {
                        if isPlayingAll {
                            soundManager.pauseAudio()
                            isPlayingAll = false
                        } else {
                            if soundManager.isPlaying {
                                soundManager.pauseAudio()
                            } else {
                                playAll()
                                
                                
                            }
                            isPlayingAll = true
                        }
                    }) {
                        if isPlayingAll {
                            Image(systemName: "stop")
                        } else {
                            Image(systemName: soundManager.isPlaying ? "stop" : "play")
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    Spacer()
                    
                    Button(action: playNext) {
                        Image(systemName: "forward.fill")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .disabled(playButtonId == surahFetch.surahDetail.count - 1) // Disable button when at last surah
                    
                    
                    
                    
                    
                }
                            }
                            .padding()
                        }
            
                .padding([.leading, .trailing], 14)
          
        }
        .onAppear{
            self.surahFetch.getSurah(surahId: self.number)
        }
        
        .navigationTitle(Text("\(self.title)"))
    }
    
    private func isSurahPlaying(_ surahID: Int) -> Bool {
        return playButtonId == surahID && soundManager.isPlaying
    }
    
    func getPlaybackDuration() -> Double {
            guard let player = audioPlayer else {
                return 0
            }
         
            return player.currentItem?.duration.seconds ?? 0
        }
    
    private func playPrevious() {
            guard playButtonId > 0 else { return }
            let previousSurah = surahFetch.surahDetail[playButtonId - 1]
            soundManager.playAudio(sound: previousSurah.audio)
            playButtonId -= 1
        }

        private func playNext() {
            guard playButtonId < surahFetch.surahDetail.count - 1 else { return }
            let nextSurah = surahFetch.surahDetail[playButtonId + 1]
            soundManager.playAudio(sound: nextSurah.audio)
            playButtonId += 1
        }
  
    private func playAll() {
        guard !surahFetch.surahDetail.isEmpty else { return }
      
        
        let nextSurah = surahFetch.surahDetail[playButtonId]
        
      
        
        var audioURLs: [String] = []
        for data in surahFetch.surahDetail {
           
            audioURLs.append(data.audio)
           
        }
        
        soundManager.playAudioMany(urls: audioURLs)
        isPlayingAll = true
        
        
    }

       
    
}

struct Indicator : UIViewRepresentable{
    
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.lightGray
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}

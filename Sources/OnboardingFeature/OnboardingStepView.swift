import ComposableArchitecture
import Styleguide
import SwiftUI

struct OnboardingStepView: View {
  let store: Store<OnboardingState, OnboardingAction>
  @ObservedObject var viewStore: ViewStore<ViewState, OnboardingAction>
  @Environment(\.colorScheme) var colorScheme

  init(store: Store<OnboardingState, OnboardingAction>) {
    self.store = store
    self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
  }

  struct ViewState: Equatable {
    let isGetStartedButtonVisible: Bool
    let isNextButtonVisible: Bool
    let isSubmitButtonVisible: Bool
    let presentationStyle: OnboardingState.PresentationStyle
    let step: OnboardingState.Step

    init(onboardingState state: OnboardingState) {
      self.isGetStartedButtonVisible = state.step == OnboardingState.Step.allCases.last
      self.isNextButtonVisible =
        state.step != OnboardingState.Step.allCases.first
        && state.step.isFullscreen
        && state.step != OnboardingState.Step.allCases.last

      switch state.step {
      case .step5_Submit:
        self.isSubmitButtonVisible = state.game.selectedWordString == "GAME"
      case .step8_FindCubes:
        self.isSubmitButtonVisible = state.game.selectedWordString == "CUBES"
      case .step12_CubeIsShaking:
        self.isSubmitButtonVisible = state.game.selectedWordString == "REMOVE"
      case .step16_FindAnyWord:
        self.isSubmitButtonVisible = !state.game.selectedWordString.isEmpty
      default:
        self.isSubmitButtonVisible = false
      }

      self.presentationStyle = state.presentationStyle
      self.step = state.step
    }
  }

  var body: some View {
    GeometryReader { proxy in
      let height = proxy.size.height / 4

      ZStack(alignment: .bottom) {
        VStack {
          if self.viewStore.step.isFullscreen {
            Spacer()
          }

          Group {
            Group {
              if self.viewStore.step == .step1_Welcome {
                FullscreenStepView(
                  Text("Hello!\nWelcome\nto ")
                    + Text("isowords").fontWeight(.medium)
                    + Text(", a\nword game.")
                )
              }
              if self.viewStore.step == .step2_FindWordsOnCube {
                FullscreenStepView(
                  Text("The point of\n")
                    + Text("the game is\n")
                    + Text("to find words\n")
                    + Text("on a ") + Text("cube").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step3_ConnectLettersTouching {
                FullscreenStepView(
                  Text("Words are\n")
                    + Text("formed by\n")
                    + Text("connecting\n")
                    + Text("letters that are\n")
                    + Text("touching").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step4_FindGame {
                InlineStepView(
                  height: height,
                  Text("Let's try!\n")
                    + Text("Connect letters\n")
                    + Text("to form ") + Text("GAME").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step5_Submit {
                InlineStepView(
                  height: height,
                  Text("Now submit the\n")
                    + Text("word by tapping\n")
                    + Text("the ") + Text("thumbs up").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step6_Congrats {
                InlineStepView(
                  height: height,
                  Text("Well done!")
                )
              }
              if self.viewStore.step == .step7_BiggerCube {
                FullscreenStepView(
                  Text("Let’s find\n")
                    + Text("another word,\n")
                    + Text("but this time\n")
                    + Text("with more\n")
                    + Text("letters revealed").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step8_FindCubes {
                InlineStepView(
                  height: height,
                  Text("Find and submit\n")
                    + Text("the word ") + Text("CUBES").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step9_Congrats {
                InlineStepView(
                  height: height,
                  Text("You got it!")
                )
              }
              if self.viewStore.step == .step10_CubeDisappear {
                FullscreenStepView(
                  Text("You can use\n")
                    + Text("each letter three\n")
                    + Text("times before the\n")
                    + Text("cube ") + Text("disappears").fontWeight(.medium) + Text(".")
                )
              }
            }
            Group {
              if self.viewStore.step == .step11_FindRemove {
                InlineStepView(
                  height: height,
                  Text("Let’s try it!\n")
                    + Text("Find the word\n")
                    + Text("REMOVE").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step12_CubeIsShaking {
                InlineStepView(
                  height: height,
                  Text("The shaking cube\n")
                    + Text("means it will\n")
                    + Text("disappear").fontWeight(.medium) + Text(". Now\n")
                    + Text("submit the word.")
                )
              }
              if self.viewStore.step == .step13_Congrats {
                InlineStepView(
                  height: height,
                  Text("Ohhhhhhh,\n").italic()
                    + Text("interesting!")
                )
              }
              if self.viewStore.step == .step14_LettersRevealed {
                FullscreenStepView(
                  Text("As cubes are\n")
                    + Text("removed the\n")
                    + Text("letters inside are\n")
                    + Text("revealed, helping\n")
                    + Text("you find more\n")
                    + Text("words").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step15_FullCube {
                FullscreenStepView(
                  Text("Good job so\n")
                    + Text("far, but the\n")
                    + Text("real game is\n")
                    + Text("played with all\n")
                    + Text("letters ") + Text("revealed").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step16_FindAnyWord {
                InlineStepView(
                  height: height,
                  Text("Find ") + Text("any").fontWeight(.medium) + Text(" word\n")
                    + Text("on the full cube.")
                )
              }
              if self.viewStore.step == .step17_Congrats {
                InlineStepView(
                  height: height,
                  Text("That's a great\n")
                    + Text("word!")
                )
              }
              if self.viewStore.step == .step18_OneLastThing {
                FullscreenStepView(
                  Text("One last thing.\n")
                    + Text("You can remove\n")
                    + Text("a cube by\n")
                    + Text("double tapping\n").fontWeight(.medium)
                    + Text("it. This can\n")
                    + Text("be handy\n")
                    + Text("for exposing\n")
                    + Text("more letters").fontWeight(.medium) + Text(".")
                )
              }
              if self.viewStore.step == .step19_DoubleTapToRemove {
                InlineStepView(
                  height: height,
                  Text("Let’s try it.\n")
                    + Text("Double tap\n")
                    + Text("any cube to\n")
                    + Text("remove").fontWeight(.medium) + Text(" it.")
                )
              }
            }
            Group {
              if self.viewStore.step == .step20_Congrats {
                InlineStepView(
                  height: height,
                  Text("Perfect!")
                )
              }
              if self.viewStore.step == .step21_PlayAGameYourself {
                switch self.viewStore.presentationStyle {
                case .demo:
                  FullscreenStepView(
                    Text("Ok, ready?\n")
                      + Text("Let’s try a\n")
                      + Text("3 minute timed\n")
                      + Text("game!\n")
                  )

                case .firstLaunch, .help:
                  FullscreenStepView(
                    Text("Ok, there’s more\n")
                      + Text("strategy to the\n")
                      + Text("game, but the\n")
                      + Text("only way to\n")
                      + Text("learn is to\n")
                      + Text("play a game\n").fontWeight(.medium)
                      + Text("yourself").fontWeight(.medium) + Text("!")
                  )
                }
              }
            }
          }
          .foregroundColor(
            self.colorScheme == .dark
              ? self.viewStore.step.color
              : Color.isowordsBlack
          )
          .transition(
            AnyTransition.asymmetric(
              insertion: .offset(x: 0, y: 50),
              removal: .offset(x: 0, y: -50)
            )
            .combined(with: .opacity)
          )
          // NB: The zIndex works around a bug. While transitioning a view
          //     out it will snap behind the cube view for some reason.
          .zIndex(1)
          .multilineTextAlignment(.center)

          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .adaptivePadding([.leading, .trailing])
        .padding(.bottom, 80)

        Group {
          if self.viewStore.isNextButtonVisible {
            Button(
              action: {
                self.viewStore.send(.nextButtonTapped, animation: .default)
              }
            ) {
              Image(systemName: "arrow.right")
                .frame(width: 80, height: 80)
                .background(
                  self.colorScheme == .dark
                    ? self.viewStore.step.color
                    : Color.isowordsBlack
                )
                .foregroundColor(
                  self.colorScheme == .dark
                    ? Color.isowordsBlack
                    : self.viewStore.step.color
                )
                .font(.system(size: 30))
                .clipShape(Circle())
            }
          } else if !self.viewStore.step.isFullscreen {
            if self.viewStore.isSubmitButtonVisible {
              Button(
                action: {
                  self.viewStore.send(.game(.submitButtonTapped(nil)), animation: .default)
                }
              ) {
                Image(systemName: "hand.thumbsup")
                  .frame(width: 80, height: 80)
                  .background(
                    self.colorScheme == .dark
                      ? self.viewStore.step.color
                      : Color.isowordsBlack
                  )
                  .foregroundColor(
                    self.colorScheme == .dark
                      ? Color.isowordsBlack
                      : self.viewStore.step.color
                  )
                  .font(.system(size: 30))
                  .clipShape(Circle())
              }
            }
          } else if self.viewStore.isGetStartedButtonVisible {
            Button(
              action: {
                self.viewStore.send(.getStartedButtonTapped, animation: .default)
              }
            ) {
              HStack {
                switch self.viewStore.presentationStyle {
                case .demo:
                  Text("Let’s play!")
                case .firstLaunch, .help:
                  Text("Get started")
                }
                Spacer()
                Image(systemName: "arrow.right")
              }
            }
            .buttonStyle(
              ActionButtonStyle(
                backgroundColor: self.colorScheme == .dark
                  ? self.viewStore.step.color
                  : .isowordsBlack,
                foregroundColor: self.colorScheme == .dark
                  ? .isowordsBlack
                  : self.viewStore.step.color
              )
            )
          }
        }
        .padding()
        .transition(
          AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: 50),
            removal: .offset(x: 0, y: 50)
          )
          .combined(with: .opacity)
        )
      }
    }
    .onAppear { self.viewStore.send(.onAppear) }
    .alert(self.store.scope(state: \.alert, action: OnboardingAction.alert))
  }
}

private struct FullscreenStepView: View {
  let text: Text

  init(_ text: Text) {
    self.text = text
  }

  var body: some View {
    self.text
      .adaptiveFont(.matter, size: 40)
  }
}

private struct InlineStepView: View {
  let height: CGFloat
  let text: Text

  init(height: CGFloat, _ text: Text) {
    self.height = height
    self.text = text
  }

  var body: some View {
    self.text
      .adaptiveFont(.matter, size: 28)
      .frame(height: self.height)
  }
}

extension OnboardingState.Step {
  var color: Color {
    let t = Double(self.rawValue) / Double(Self.allCases.count - 1)
    return Color(
      red: (t * 0xE1 + (1 - t) * 0xF3) / 0xFF,
      green: (t * 0x66 + (1 - t) * 0xEB) / 0xFF,
      blue: (t * 0x5B + (1 - t) * 0xA4) / 0xFF
    )
  }
}

#if DEBUG
  import Overture
  import SwiftUIHelpers

  struct OnboardingStepView_Previews: PreviewProvider {
    static var previews: some View {
      Preview {
        OnboardingStepView(
          store: Store(
            initialState: .init(
              presentationStyle: .firstLaunch,
              step: OnboardingState.Step.step16_FindAnyWord
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment(
              audioPlayer: .noop,
              backgroundQueue: DispatchQueue.global(qos: .background).eraseToAnyScheduler(),
              dictionary: .everyString,
              feedbackGenerator: .live,
              lowPowerMode: .false,
              mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
              mainRunLoop: RunLoop.main.eraseToAnyScheduler(),
              userDefaults: .noop
            )
          )
        )
      }
    }
  }
#endif
import ComposableArchitecture
import CubeCore
import SelectionSoundsCore
import SharedModels

public struct ReplayState: Equatable {
  var cubes: Puzzle
  var moves: Moves
  var nub: CubeSceneView.ViewState.NubState
  var selectedWord: [IndexedCubeFace]
  var selectedWordIsValid: Bool

  public var selectedWordString: String {
    self.cubes.string(from: self.selectedWord)
  }
}

public enum ReplayAction: Equatable {
  case begin(moveIndex: Int)
  case deselectLastFace
  case enableSubmitButton
  case end(finalCubes: Puzzle)
  case lastTurnMoves
  case nub(BindingAction<CubeSceneView.ViewState.NubState>)
  case playMove(Move)
  case selectFace(IndexedCubeFace)
}

extension Reducer where State == GameState, Action == GameAction, Environment == GameEnvironment {
  func replay() -> Self {
    self
      .combined(
        with: .init { state, action, environment in
          switch action {
          case .onAppear:
//            guard state.gameContext.isTurnBased
//            else { return .none }

            let previousMoves = Moves(state.moves.dropLast())
            let cubes = Puzzle(
              archivableCubes: .init(cubes: state.cubes),
              moves: previousMoves
            )
            let replayMoves = state.moves.suffix(1)

            state.replay = .init(
              cubes: cubes,
              moves: previousMoves,
              nub: .init(duration: 0, location: .offScreenRight, isPressed: false),
              selectedWord: [],
              selectedWordIsValid: false
            )

            let tap: Effect<GameAction, Never> = .concatenate(
              // Press the nub
              Effect(value: .replay(.nub(.set(\.isPressed, true))))
                .receive(on: environment.mainQueue.animate(withDuration: submitPressDuration))
                .eraseToEffect(),

              // Release the nub
              Effect(value: .replay(.nub(.set(\.isPressed, false))))
                .delay(
                  for: .seconds(submitPressDuration),
                  scheduler: environment.mainQueue.animate(withDuration: 0.3)
                )
                .eraseToEffect()
            )

            var effects: [Effect<GameAction, Never>] = [
              Effect.none
                .delay(for: state.isGameLoaded ? 1 : firstWordDelay, scheduler: environment.mainQueue)
                .eraseToEffect()
            ]

            for (index, move) in zip(replayMoves.indices, replayMoves) {
              switch move.type {
              case let .playedWord(word):
                // Wait a small about of time before each word
                effects.append(
                  Effect.none
                    .delay(for: firstCharacterDelay, scheduler: environment.mainQueue)
                    .eraseToEffect()
                )

                // Play each character in the word
                for (characterIndex, character) in word.enumerated() {
                  let face = IndexedCubeFace(index: character.index, side: character.side)

                  // Move the nub to the face being played
                  effects.append(
                    Effect(value: .replay(.nub(.set(\.location, .face(face)))))
                      .receive(
                        on: environment.mainQueue
                          .animate(withDuration: moveNubToFaceDuration, options: .curveEaseInOut)
                      )
                      .eraseToEffect()
                  )
                  effects.append(
                    Effect.merge(
                      // Press the nub on the first character
                      characterIndex == 0 ? Effect(value: .replay(.nub(.set(\.isPressed, true)))) : .none,
                      // Tap on each face in the word being played
                      Effect(value: .replay(.selectFace(face)))
                    )
                    .delay(
                      for: .seconds(
                        characterIndex == 0
                          ? moveNubToFaceDuration
                          : .random(in: (0.3 * moveNubToFaceDuration)...(0.7 * moveNubToFaceDuration))
                      ),
                      scheduler: environment.mainQueue.animation()
                    )
                    .eraseToEffect()
                  )
                }
                effects.append(Effect(value: .replay(.enableSubmitButton)))

                // Release the nub when the last character is played
                effects.append(
                  Effect(value: .replay(.nub(.set(\.isPressed, false))))
                    .receive(on: environment.mainQueue.animate(withDuration: 0.3))
                    .eraseToEffect()
                )
                // Move the nub to the submit button
                effects.append(
                  Effect(value: .replay(.nub(.set(\.location, .submitButton))))
                    .delay(
                      for: 0.2,
                      scheduler: environment.mainQueue
                        .animate(withDuration: moveNubToSubmitButtonDuration, options: .curveEaseInOut)
                    )
                    .eraseToEffect()
                )
                // Submit the word after waiting a small amount of time
                effects.append(
                  Effect(value: .replay(.playMove(move)))
                    .delay(
                      for: .seconds(
                        .random(
                          in:
                            moveNubToSubmitButtonDuration...(moveNubToSubmitButtonDuration
                                                              + submitHesitationDuration)
                        )
                      ),
                      scheduler: environment.mainQueue.animation()
                    )
                    .eraseToEffect()
                )
                effects.append(tap)

              case let .removedCube(latticePoint):
                break
//                let side = CubeFace.Side(rawValue: index % CubeFace.Side.allCases.count)!
//
//                effects.append(contentsOf: [
//                  // Move the nub to the cube
//                  Effect(value: .replay(.nub(.set(\.location, .latticePoint(latticePoint)))))
//                    .delay(
//                      for: 0.2,
//                      scheduler: environment.mainQueue
//                        .animate(withDuration: moveNubToSubmitButtonDuration, options: .curveEaseInOut)
//                    )
//                    .eraseToEffect(),
//
//                  // Double-tap
//                  tap
//                    .delay(for: 0.65, scheduler: environment.mainQueue)
//                    .eraseToEffect(),
//
//                  Effect(value: .replay(.selectFace(IndexedCubeFace(index: latticePoint, side: side)))),
//
//                  tap
//                    .delay(for: 0.2, scheduler: environment.mainQueue)
//                    .eraseToEffect(),
//
//                  Effect(value: .replay(.deselectLastFace)),
//                ])
//
//                // Remove the cube
//                effects.append(
//                  Effect(value: .replay(.playMove(move)))
//                    .delay(for: 0.2, scheduler: environment.mainQueue)
//                    .eraseToEffect()
//                )
              }
            }
//
//            // Move the nub off screen once all words have been played
//            effects.append(
//              Effect(value: .nub(.set(\.location, .offScreenBottom)))
//                .delay(for: .seconds(0.3), scheduler: environment.mainQueue)
//                .receive(
//                  on: environment.mainQueue
//                    .animate(withDuration: moveNubOffScreenDuration, options: .curveEaseInOut)
//                )
//                .eraseToEffect()
//            )
//
//            return Effect.concatenate(
//              Effect.concatenate(effects)
//                .cancellable(id: ReplayId()),
//
//              .init(value: .replay(.end(finalCubes: finalCubes)))
//            )
//            .cancellable(
//              id: { struct Id: Hashable {}; return Id() }(),
//              cancelInFlight: true
//            )

            return .none




          case .replay(.deselectLastFace):
            guard state.replay?.selectedWord.isEmpty == false else { return .none }
            state.replay?.selectedWord.removeLast()
            return environment.feedbackGenerator.selectionChanged()
              .fireAndForget()

          case .replay(.enableSubmitButton):
            state.replay?.selectedWordIsValid = true
            return .none

          case let .replay(.end(cubes)):
            state.replay = nil
            return .none

          case .replay(.lastTurnMoves):
            return .none
//            let game = state
//            guard
//              !game.isGameOver,
//              let turnBasedContext = game.turnBasedContext,
//    //          let lastOpenedAt = turnBasedContext.metadata.lastOpenedAt,
//    //          lastOpenedAt < turnBasedContext.lastPlayedAt,
//              let localPlayerIndex = turnBasedContext.localPlayerIndex,
//              let replayStartIndex = game.moves.index(
//                game.moves
//                  .lastIndex(where: { $0.playerIndex == turnBasedContext.localPlayerIndex }) ?? -1,
//                offsetBy: 1, limitedBy: game.moves.endIndex
//              )
//            else { return .none }
//
//            guard turnBasedContext.currentParticipantIsLocalPlayer
//            else {
//              let previousMoves = Moves(game.moves[..<replayStartIndex])
//              state.replay?.moves = previousMoves
//              state.replay?.cubes = Puzzle(
//                archivableCubes: .init(cubes: game.cubes),
//                moves: previousMoves
//              )
//              return .none
//            }
//
//            return Effect(value: .replay(.begin(moveIndex: replayStartIndex)))

          case let .replay(.playMove(move)):
            state.replay?.moves.append(move)
            if var cubes = state.replay?.cubes {
              apply(move: move, to: &cubes)
              state.replay?.cubes = cubes
            }
            state.replay?.selectedWord = []
            state.replay?.selectedWordIsValid = false
            return .none

          case let .replay(.selectFace(index)):
            state.replay?.selectedWord.append(index)
            return .none

          default:
            return .none
          }
        }
      )
      .haptics(
        feedbackGenerator: \.feedbackGenerator,
        isEnabled: { _ in true },
        triggerOnChangeOf: { $0.replay?.selectedWord }
      )
      .selectionSounds(
        audioPlayer: \.audioPlayer,
        contains: { _, environment, word in environment.dictionary.contains(word, .en) },
        hasBeenPlayed: { _, _ in false },
        puzzle: { $0.replay?.cubes ?? .mock },
        selectedWord: { $0.replay?.selectedWord ?? [] }
      )
  }
}

private let firstCharacterDelay: DispatchQueue.SchedulerTimeType.Stride = 0.3
private let firstWordDelay: DispatchQueue.SchedulerTimeType.Stride = 2.5
private let moveNubToFaceDuration = 0.45
private let moveNubToSubmitButtonDuration = 0.4
private let moveNubOffScreenDuration = 0.5
private let fadeInDuration = 0.3
private let fadeOutDuration = 0.3
private let submitPressDuration = 0.05
private let submitHesitationDuration = 0.15
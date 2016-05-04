/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import AudioToolbox
import ResearchKit

let tappingDuration = NSTimeInterval(5)

struct StudyTasks {
    
    static let microphoneTask: ORKOrderedTask = {
        let intendedUseDescription = "Everyone's voice has unique characteristics."
        let speechInstruction = "After the countdown, say Aaaaaaaaaaah for as long as you can. You'll have 10 seconds."
        let shortSpeechInstruction = "Say Aaaaaaaaaaah for as long as you can."
        
        return ORKOrderedTask.audioTaskWithIdentifier("AudioTask", intendedUseDescription: intendedUseDescription, speechInstruction: speechInstruction, shortSpeechInstruction: shortSpeechInstruction, duration: 10, recordingSettings: nil, options: ORKPredefinedTaskOption.ExcludeAccelerometer)
    }()
    
    static let tappingTask: ORKOrderedTask = {
        let intendedUseDescription = "Finger tapping is a universal way to communicate."
        
        return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier("TappingTask", intendedUseDescription: intendedUseDescription, duration: tappingDuration, options: ORKPredefinedTaskOption.None) // CHANGED: Duration: 10
    }()
    
    static let walkingTask: ORKOrderedTask = {
        let intendedUseDescription = "Short walking task to evaluate gait and balance."
        
        return ORKOrderedTask.shortWalkTaskWithIdentifier("WalkingTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 10, restDuration: NSTimeInterval(5), options: ORKPredefinedTaskOption.None)
    }()
    
    static let reactionTask: ORKOrderedTask = {
        let intendedUseDescription = "Test to evaluate reaction time."
        
        return ORKOrderedTask.reactionTimeTaskWithIdentifier("ReactionTask", intendedUseDescription: intendedUseDescription, maximumStimulusInterval: NSTimeInterval(10), minimumStimulusInterval: NSTimeInterval(2), thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: NSTimeInterval(1), successSound: 1054, timeoutSound: 1052, failureSound: 1053, options: ORKPredefinedTaskOption.None)
    }()
    
    static let heartRateTask: ORKOrderedTask = {
        return ORKOrderedTask.fitnessCheckTaskWithIdentifier("HeartRateTask",
            intendedUseDescription: nil,
            walkDuration: 15 as NSTimeInterval,
            restDuration: 15 as NSTimeInterval,
            options: .None)
    }()
    

    
    static let surveyTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Knoweledge of the Universe Survey"
        instructionStep.text = "Please answer these 6 questions to the best of your ability. It's okay to skip a question if you don't know the answer."
        
        steps += [instructionStep]
        
        // Quest question using text choice
        let questQuestionStepTitle = "Which of the following is not a planet?"
        let textChoices = [
            ORKTextChoice(text: "Saturn", value: 0),
            ORKTextChoice(text: "Uranus", value: 1),
            ORKTextChoice(text: "Pluto", value: 2),
            ORKTextChoice(text: "Mars", value: 3)
        ]
        let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices)
        let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
        
        steps += [questQuestionStep]
        
        // Name question using text input
        let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 25)
        nameAnswerFormat.multipleLines = false
        let nameQuestionStepTitle = "What do you think the next comet that's discovered should be named?"
        let nameQuestionStep = ORKQuestionStep(identifier: "NameQuestionStep", title: nameQuestionStepTitle, answer: nameAnswerFormat)
        
        steps += [nameQuestionStep]
        
        let shapeQuestionStepTitle = "Which shape is the closest to the shape of Messier object 101?"
        let shapeTuples = [
            (UIImage(named: "square")!, "Square"),
            (UIImage(named: "pinwheel")!, "Pinwheel"),
            (UIImage(named: "pentagon")!, "Pentagon"),
            (UIImage(named: "circle")!, "Circle")
        ]
        let imageChoices : [ORKImageChoice] = shapeTuples.map {
            return ORKImageChoice(normalImage: $0.0, selectedImage: nil, text: $0.1, value: $0.1)
        }
        let shapeAnswerFormat: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(imageChoices)
        let shapeQuestionStep = ORKQuestionStep(identifier: "ImageChoiceQuestionStep", title: shapeQuestionStepTitle, answer: shapeAnswerFormat)
        
        steps += [shapeQuestionStep]
        
        // Date question
        let today = NSDate()
        let dateAnswerFormat =  ORKAnswerFormat.dateAnswerFormatWithDefaultDate(nil, minimumDate: today, maximumDate: nil, calendar: nil)
        let dateQuestionStepTitle = "When is the next solar eclipse?"
        let dateQuestionStep = ORKQuestionStep(identifier: "DateQuestionStep", title: dateQuestionStepTitle, answer: dateAnswerFormat)
        
        steps += [dateQuestionStep]
        
        // Boolean question
        let booleanAnswerFormat = ORKBooleanAnswerFormat()
        let booleanQuestionStepTitle = "Is Venus larger than Saturn?"
        let booleanQuestionStep = ORKQuestionStep(identifier: "BooleanQuestionStep", title: booleanQuestionStepTitle, answer: booleanAnswerFormat)
        
        steps += [booleanQuestionStep]
        
        // Continuous question
        let continuousAnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(150, minimumValue: 30, defaultValue: 20, step: 10, vertical: false, maximumValueDescription: "Objects", minimumValueDescription: " ")
        let continuousQuestionStepTitle = "How many objects are in Messier's catalog?"
        let continuousQuestionStep = ORKQuestionStep(identifier: "ContinuousQuestionStep", title: continuousQuestionStepTitle, answer: continuousAnswerFormat)
        
        steps += [continuousQuestionStep]
        
        // Summary step
        
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
    }()
    
    static let watchTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Watch Accelerometer Test"
        instructionStep.text = "Test to gather watch accelerometer data"
        
        steps += [instructionStep]

        let countdownStep = ORKCountdownStep(identifier: "CountdownStep")
        
        steps += [countdownStep]
        
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "WatchTask", steps: steps)
    }()
    
}

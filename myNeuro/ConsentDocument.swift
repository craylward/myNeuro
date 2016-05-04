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

import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    let ipsum = [
        "This overview explains the research study. After you learn about the study, you can choose if you would like to participate. This may take about 20 minutes to complete. This simple walkthrough will help you understand the study, the impact it will have on your life, and will allow you to provide consent to participate.\n\nTALK ABOUT THE PURPOSE OF THE STUDY AND SOME BACKGROUND ON PARKINSON'S.",
        "This study will gather location and sensor data from your phone and fitness devices with your permission. You can choose not to do this and still participate in the study.\n\nTALK ABOUT HOW/WHY THE APP WILL COLLECT LOCATION AND SENSOR DATA.",
        "To protect you privacy, we will use a random code instead of your name on your study data.\n\nTALK ABOUT HOW PRIVACY WILL BE PROTECTED AND THE SLIGHT RISK OF BEING ABLE TO LINK NAME TO DATA.",
        "We will not share you information with any third parties such as advertisers.\n\nTALK ABOUT HOW DATA WILL ONLY BE SHARED WITH US.",
        "This study will take about 20 minutes per day. Monthly reviews may take an additional 5 minutes once a month.\n\nTALK MORE ABOUT THE TIME COMMITMENT INVOLVED WITH STUDY.",
        "Surveys are an important part of this research study. We will ask you to complete weekly and monthly surveys about your health.\n\nTALK ABOUT SURVEY QUESTIONS",
        "To understand changes in your health, we will ask you to complete surveys and simple activities daily and weekly. We will look for patterns over time.\n\nTALK MORE ABOUT THE STUDY TASKS THAT THE PARTICIAPNT WILL BE DOING.",
        "There will be no penalty to you if you decide not to take part in this study. You can withdraw your consent and discontinue participation at any time.\n\nTALK MORE ABOUT WITHDRAWAL."
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        title = NSLocalizedString("Research Health Study Consent Form", comment: "")
        
        let sectionTypes: [ORKConsentSectionType] = [
            .Overview,
            .DataGathering,
            .Privacy,
            .DataUse,
            .TimeCommitment,
            .StudySurvey,
            .StudyTasks,
            .Withdrawing
        ]
        
        sections = zip(sectionTypes, ipsum).map { sectionType, ipsum in
            let section = ORKConsentSection(type: sectionType)
            
            let localizedIpsum = NSLocalizedString(ipsum, comment: "")
            let localizedSummary = localizedIpsum.componentsSeparatedByString(".")[0] + "."
            
            section.summary = localizedSummary
            section.content = localizedIpsum
            
            return section
        }

        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {

    public var description: String {
        switch self {
            case .Overview:
                return "Overview"
                
            case .DataGathering:
                return "DataGathering"
                
            case .Privacy:
                return "Privacy"
                
            case .DataUse:
                return "DataUse"
                
            case .TimeCommitment:
                return "TimeCommitment"
                
            case .StudySurvey:
                return "StudySurvey"
                
            case .StudyTasks:
                return "StudyTasks"
                
            case .Withdrawing:
                return "Withdrawing"
                
            case .Custom:
                return "Custom"
                
            case .OnlyInDocument:
                return "OnlyInDocument"
        }
    }
}
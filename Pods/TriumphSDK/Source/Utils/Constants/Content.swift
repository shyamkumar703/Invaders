//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

struct Content {

    struct Tournaments {
        static let prizePool = "tournament_prize_pool"
        static let versusTitle = "tournament_versus_title"
        static let entryTitlePeople = "tournament_entry_title_people"
        static let enrtyTitlePrice = "tournament_entry_title_price"
        static let entryTitleTicket = "tournament_entry_title_ticket"
        static let dollarSignIcon = "dollarsign.square.fill"
        static let ticketIcon = "ticket"
        static let hostAppURLString = "itms-apps://itunes.apple.com/app/triumph-host/id1595159783"
        static let welcomeCellTitle = "welcome_cell_title"
        static let welcomeCellSubtitle = "welcome_cell_subtitle"
        static let currentAppURLString = "https://apps.apple.com/ar/app/triumph-tournaments/id1560917953?l=en"
    }
    
    struct ApplePay {
        static let checkoutErrorMsg = "applepay_checkout_err_msg"
        static let requestErrorMsg = "applepay_request_err_msg"
        static let controllerErrorMsg = "applepay_controller_err_msg"
        static let paymentErrorTitle = "applepay_payment_err_title"
    }
    
    struct PhoneOTP {
        static let phoneTitle = "phoneotp_phone_title"
        static let phoneNumberPlaceholder = "phoneotp_phone_number_placeholder"
        static let codeTitle = "phoneotp_code_title"
        static let changeNumberButtonTitle = "phoneotp_change_number_button_title"
        static let codePlaceholder = "phoneotp_code_placeholder"
        static let sendCodeTitle = "phoneotp_send_code_title"
        static let charmRdTimes = "phoneotp_charm_rd_times"
        static let charmThTimes = "phoneotp_charm_th_times"
        static let phoneNumberErrorTitle = "phoneotp_phone_number_err_title"
        static let phoneNumberErrorMessage = "phoneotp_phone_number_err_msg"
        static let wrongCodeTitle = "phoneotp_wrong_code_title"
        static let wrongCodeMessage = "phoneotp_wrong_code_msg"
        static let codeAttemptsExceededTitle = "phoneotp_code_attempts_exceeded_title"
        static let codeAttemptsExceededMessage = "phoneotp_code_attempts_exceeded_msg"
        static let usNumberWarning = "phoneotp_us_number_only_msg"
    }
    
    struct Matching {
        static let vcTitle = "ready_to_play_vs"
        static let opponentTitle = "ready_to_play_opponent_title"
        static let playerTitle = "ready_to_play_player_title"
        static let items = [
            ("battery.100.bolt",   "ready_to_play_enough_power_title"),
            ("moon.fill",          "ready_to_play_silence_title"),
            ("lock.fill",          "ready_to_play_locked_in")

        ]
        static let buttonStartTitle = "ready_to_play_button_start_title"
        static let countdownLabelFinishTitle = "ready_to_play_countdown_lbl_finish_title"
        static let error = "error"
        static let rngError = "error getting random number seed"
        static let notEligibleTitle = "not_eligible_title"
        static let notEligibleMessage = "not_eligible_message"
        
    }
    
    struct GameOver {
        static let scoreTitle = "game_over_score_title"
        static let wonTitle = "game_over_you_won_title"
        static let lostTitle = "game_over_you_lost_title"
        static let playAgainTitle = "game_over_btn_play_again_title"
        static let opponentPlayingTitle = "game_over_opponent_playing"
    }
    
    struct Cashout {
        static let title = "cashout_title"
        static let items = [
            ("square.and.arrow.down",                "cashout_1_step"),
            ("person.crop.circle.badge.checkmark",   "cashout_2_step"),
            ("creditcard",                           "cashout_3_step")
        ]
        static let continueButtonTitle = "cashout_continue_btn_title"
    }
    
    struct Support {
        static let title = "support_title"
        static let primaryRows = [
            ("support_1_row_title", "support_1_row_subtitle"),
        ]
        static let faqTitle = "support_header_faq_title"
        static let questions = [
            ("support_question_1", "support_question_1_details"),
            ("support_question_2", "support_question_2_details"),
            ("support_question_3", "support_question_3_details"),
            ("support_question_4", "support_question_4_details"),
            ("support_question_5", "support_question_5_details"),
            ("support_question_6", "support_question_6_details"),
            ("support_question_7", "support_question_7_details"),
            ("support_question_8", "support_question_8_details"),
            ("support_question_9", "support_question_9_details"),
            ("support_question_10", "support_question_10_details"),
            ("support_question_11", "support_question_11_details"),
            ("support_question_12", "support_question_12_details"),
            ("support_question_13", "support_question_13_details"),
            ("support_question_14", "support_question_14_details"),
            ("support_question_15", "support_question_15_details"),
            ("support_question_16", "support_question_16_details")

        ]
    }
    
    struct LiveMessage {
        static let loading = "live_message_loading"
    }
    
    struct Error {
        static let serverUnavailable = "server_unavailable"
        static let serverUnavailableDetails = "server_unavailable_details"
    }
}

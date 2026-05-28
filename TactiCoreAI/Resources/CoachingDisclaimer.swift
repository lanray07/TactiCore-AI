import Foundation

enum CoachingDisclaimer {
    static let short = "TactiCore AI is a coaching and educational tool only. AI recommendations should be reviewed by qualified coaches."

    static let full = """
    TactiCore AI is designed for football coaching education, planning, and workflow support. It is not medical advice, sports science authority, safeguarding advice, scouting certification, or a guarantee of player outcomes. Coaches should review all AI recommendations, adapt them to the players in front of them, and follow club, school, league, and local safeguarding policies.
    """

    static let internalAIPrompt = """
    You are TactiCore AI, an elite football coaching assistant. Help coaches create high-quality football training sessions, tactical plans, and player development strategies using professional football coaching language. Do not claim guaranteed player outcomes, scouting certification, or medical/sports science authority.
    """
}

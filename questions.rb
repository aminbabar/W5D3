require 'sqlite3'
require 'singleton'


class QuestionsDatabase < SQLite3::Database
    include Singleton
    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end


class Question

    attr_accessor :id, :title, :body, :user_id

    def self.find_by_id(id)
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL
        return Question.new(question[0])      
    end


    def self.find_by_author_id(author_id)
        question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT *
            FROM questions
            WHERE user_id = ?
        SQL
        question.map {|hash| Question.new(hash)}
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

    def initialize(attributes)
        @id = attributes['id']
        @title = attributes['title']
        @body = attributes['body']
        @user_id = attributes['user_id']
    end


    def author
        User.find_by_id(user_id)
    end

    def replies
        Reply.find_by_question_id(id)
    end

    def followers
        QuestionFollow.follower_for_question_id(id)
    end

    def likers 
        QuestionLikes.likers_for_question_id(id)
    end

    def num_likes 
        QuestionLikes.num_likes_for_question_id(id)
    end
end


class User

    attr_accessor :id, :fname, :lname

    def self.find_by_id(id)
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM users
            WHERE id = ?
        SQL
        return User.new(user[0])      
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT *
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        return User.new(user[0]) 
    end


    def initialize(attributes) 
        @id = attributes['id']
        @fname = attributes['fname']
        @lname = attributes['lname']
    end


    def authored_questions
        Question.find_by_author_id(id)
    end

    def authored_replies
        Reply.find_by_user_id(id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(id)
    end 

    def average_karma
        average = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT COUNT(*) / (COUNT(SELECT COUNT(*) FROM question_likes))
            FROM questions
            JOIN question_likes ON questions.id = question_likes.user_id
            WHERE questions.user_id = ?
        SQL
    end



end


class QuestionFollow

    attr_accessor :id, :question_id, :user_id

    def self.find_by_id(id)
        questionfollow = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_follows
            WHERE id = ?
        SQL
        return QuestionFollow.new(questionfollow[0])      
    end

    def self.follower_for_question_id(question_id)
        questionfollow = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT users.id, users.fname, users.lname
        FROM users
        JOIN question_follows ON users.id = question_follows.user_id
        WHERE question_follows.question_id = ?
        SQL
        questionfollow.map { |user| User.new(user) }
    end

    def self.followed_questions_for_user_id(user_id)
        followquestions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT questions.id, questions.title, questions.body, questions.user_id
        FROM questions
        JOIN question_follows ON questions.id = question_follows.question_id
        WHERE question_follows.user_id = ?
        SQL
        followquestions.map { |question| Question.new(question) }
    end

    def self.most_followed_questions(n)
        followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT questions.id, questions.title, questions.body, questions.user_id
            FROM question_follows
            JOIN questions ON questions.id = question_follows.question_id
            GROUP BY questions.user_id
            ORDER BY COUNT(*) DESC
            LIMIT ?
        SQL
        followed_questions.map {|question| Question.new(question)}
    end

    def initialize(attributes)
        @id = attributes['id']
        @question_id = attributes['question_id']
        @user_id = attributes['user_id']
    end

end

class Reply

    attr_accessor :id, :question_id, :reply_id, :user_id, :body

    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM replies
            WHERE user_id = ?
        SQL
        replies.map {|hash| Reply.new(hash)}
    end

    def self.find_by_id(id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        return Reply.new(reply[0])      
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM replies
            WHERE question_id = ?
        SQL
        replies.map {|hash| Reply.new(hash)}
    end

    def initialize(attributes)
        @id = attributes['id']
        @question_id = attributes['question_id']
        @reply_id = attributes['reply_id']
        @user_id = attributes['user_id']
        @body = attributes['body']
    end

    def author
        User.find_by_id(user_id)
    end

    def question
        Question.find_by_id(question_id)
    end

    def parent_reply
        if Reply.find_by_id(reply_id) == nil
            raise "no parents"
        else
            return Reply.find_by_id(reply_id)
        end
    end

    def child_replies
        child_reply = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE reply_id = ?
        SQL

        return Reply.new(child_reply.first)
    end
end

class QuestionLike

    attr_accessor :id, :user_id, :question_id

    def self.likers_for_question_id(question_id)
        question_likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT users.id, users.fname, users.lname
            FROM question_likes
            JOIN users ON question_likes.user_id = users.id
            WHERE question_likes.question_id = ?
        SQL
        question_likers.map { |liker| User.new(liker) }
    end

    def self.num_likes_for_question_id(question_id)
        question_likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT COUNT(*)
            FROM question_likes
            JOIN users ON question_likes.user_id = users.id
            WHERE question_likes.question_id = ?
        SQL
        question_likers.first
    end

    def self.liked_questions_for_user_id(user_id)
        liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT questions.id, questions.title, questions.body, questions.user_id
            FROM questions
            JOIN question_likes ON questions.id = question_likes.question_id
            WHERE question_likes.user_id = ?
        SQL
        liked_questions.map { |question| Question.new(question) }
    end

    def self.find_by_id(id)
        questionlike = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        return QuestionLike.new(questionlike[0])      
    end

    def self.most_liked_questions(n)
        most_liked_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT questions.id, questions.title, questions.body, questions.user_id
            FROM questions
            JOIN question_likes ON questions.id = question_likes.question_id
            GROUP BY question_likes.question_id
            ORDER BY COUNT(*) DESC
            LIMIT ?
        SQL
        most_liked_questions.map { |question| Question.new(question) }
    end

    def initialize(attributes)
        @id = attributes['id']
        @user_id = attributes['user_id']
        @question_id = attributes['question_id']
    end

end



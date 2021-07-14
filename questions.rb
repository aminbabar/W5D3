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

    def self.find_by_id(id)
        questionlike = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        return QuestionLike.new(questionlike[0])      
    end

    def initialize(attributes)
        @id = attributes['id']
        @user_id = attributes['user_id']
        @question_id = attributes['question_id']
    end

end



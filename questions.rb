require 'sqlite3'
require 'singleton'


class QuestionsDatabase < SQLite3::Database
    include singleton
    def initialize
        super(questions.db)
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

    def initialize(attributes)
        @id = attributes['id']
        @title = attributes['title']
        @body = attributes['body']
        @user_id = attributes['user_id']
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

    def self.find_by_id(id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        return Reply.new(reply[0])      
    end

    def initialize(attributes)
        @id = attributes['id']
        @question_id = attributes['question_id']
        @reply_id = attributes['reply_id']
        @user_id = attributes['user_id']
        @body = attributes['body']
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






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
    def self.find_by_id(id)
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL
    end

    
end


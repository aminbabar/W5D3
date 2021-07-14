PRAGMA foreign_keys = ON;



-- DROP TABLE IF EXISTS plays;

-- CREATE TABLE plays (
--   id INTEGER PRIMARY KEY,
--   title TEXT NOT NULL,
--   year INTEGER NOT NULL,
--   playwright_id INTEGER NOT NULL,

--   FOREIGN KEY (playwright_id) REFERENCES playwrights(id)
-- );


DROP TABLE if exists questions;
DROP TABLE if exists users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);




CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);



DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    reply_id INTEGER,
    user_id INTEGER NOT NULL,
    body TEXT NOT NULL,


    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (reply_id) REFERENCES replies(id)
);


DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);



INSERT INTO users(fname, lname)
VALUES
 ("Eddy", "Marshall"),
 ("Amin", "Babar");


 INSERT INTO questions(title, body, user_id)
 VALUES
  ("NOTHING WORKS", "PRY: MY COMPUTER FAILS", (SELECT id FROM users WHERE fname = 'Eddy') ),
  ("WEIRD ERROR", "WEIRD TERMINAL ERROR!!!! WHYYY", (SELECT id FROM users WHERE fname = 'Amin') );


 

DROP TABLE if exists questions;
DROP TABLE if exists users;
DROP TABLE if exists question_follows;
DROP TABLE if exists question_likes;
DROP TABLE if exists replies;



PRAGMA foreign_keys = ON;

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




CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);


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
 ("Amin", "Babar"),
 ("John", "Mendez"),
 ("Casey", "Afleck"),
 ("Jessica", "Chang");


INSERT INTO questions(title, body, user_id)
VALUES
    ("NOTHING WORKS", "PRY: MY COMPUTER FAILS", (SELECT id FROM users WHERE fname = 'Eddy') ),
    ("WEIRD ERROR", "WEIRD TERMINAL ERROR!!!! WHYYY", (SELECT id FROM users WHERE fname = 'Amin') );

INSERT INTO replies(question_id, reply_id, user_id, body)
VALUES
    (1, null, 2, "Have you tried uninstalling?"),
    (1, 1, 5, "How about napping!"),
    (2, null, 4, "Show your code!!!!"),
    (1, 2, 4, "SCREW YOU!");

INSERT INTO question_follows(question_id, user_id)
VALUES
    (1, 1),
    (1, 5),
    (2, 2),
    (1, 4),
    (2, 3);


INSERT INTO question_likes(question_id, user_id)   --WE FLIPPED THE ARGUMENTS!!!
VALUES
    (2,1),
    (1,2),
    (2,5),
    (2,3),
    (1,4);

-- question, user, questionfollow, reply, questionlike,  

--     id INTEGER PRIMARY KEY,
    -- question_id INTEGER NOT NULL,
    -- reply_id INTEGER,
    -- user_id INTEGER NOT NULL,
    -- body TEXT NOT NULL,

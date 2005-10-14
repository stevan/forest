DROP TABLE IF EXISTS tree;
CREATE TABLE tree (
    id int not null primary key
   ,parent_id int references tree (id)
   ,class varchar(255) NOT NULL
   ,value varchar(255)
);

INSERT INTO tree
    ( id, parent_id, value, class )
VALUES 
    ( 1, NULL, 'root', 'Tree' )
   ,( 2, NULL, 'root2', 'Tree' )
   ,( 3, 2, 'child', 'Tree' )
;

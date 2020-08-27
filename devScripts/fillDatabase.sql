-- Fills the database with a bunch of dummy users and submissions
-- Won't delete any admins (you)
-- You will need to clear out any sessions you have of dummy users before running.
-- To run this script:
--   psql -f devScripts/fillDatabase.sql postgres://<your-username>:@localhost:5432/database_development

delete from user_sessions;
delete from users where is_admin is null;
delete from submissions;
delete from house_participations;

DO $$
BEGIN
    FOR counter IN 1..1000 LOOP
        insert into users (name, email, created_at, updated_at, verified, email_verified)
        values (cast (counter as varchar), cast (counter as varchar), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, true, true);

        insert into house_participations (user_id, house_id, join_date)
        values ((select id from users where name = cast (counter as varchar)), floor(random()*3+4), CURRENT_TIMESTAMP);

        FOR user_submissions IN 1..floor(random()*30) LOOP
            insert into submissions (user_id, time, created_at, updated_at)
            values ((select id from users where name = cast (counter as varchar)), floor(random()*100), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        END LOOP;
    END LOOP;
END; $$

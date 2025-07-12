set search_path = cvp;
ALTER TABLE prodatr ADD COLUMN validaropciones_2 BOOLEAN DEFAULT FALSE;

UPDATE prodatr SET validaropciones_2 = validaropciones;
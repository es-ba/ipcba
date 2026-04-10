"use strict"

import { TableDefinition } from "backend-plus";

export function perfiles_edad():TableDefinition{
    return {
        editable: false,
        name: 'perfiles_edad',
        fields: [
            {name:'perfil_edad', typeName:'integer', nullable: false, generatedAs:'INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1'},
            {name:'edad', typeName:'text', nullable: false},
            {name:'edad_desde', typeName:'integer', generatedAs:'ccc.extraer_edad_desde((edad)::character varying)'},
            {name:'edad_hasta', typeName:'integer', generatedAs:'ccc.extraer_edad_hasta((edad)::character varying)'},
            {name:'edad_umed', typeName:'text', generatedAs:'ccc.extraer_unidad_medida((edad)::character varying)'},
        ],
        primaryKey: ['perfil_edad'],
        constraints: [
            {constraintType: 'unique', consName: 'debe haber un único rango de edad', fields: ['edad']},
            {constraintType: 'check', consName: 'rango de edades válido para perfiles_edad', expr: `edad ~ '^(?:1\s+año|(?:[02-9]\d*|\d{2,})\s+años)$'::text OR edad ~ '^\d+-\d+\s+(?:años|meses)$'::text OR edad ~ '^≥\s\d+\s+(?:años)$'::text OR edad ~ '^<\s\d+\s+(?:años)$'::text OR edad ~ '^>\s\d+\s+(?:años)$'::text`},
        ],
    }
}

/**
 * edad text COLLATE pg_catalog."default" NOT NULL,
    edad_desde integer GENERATED ALWAYS AS (ccc.extraer_edad_desde((edad)::character varying)) STORED,
    edad_hasta integer GENERATED ALWAYS AS (ccc.extraer_edad_hasta((edad)::character varying)) STORED,
    edad_umed text COLLATE pg_catalog."default" GENERATED ALWAYS AS (ccc.extraer_unidad_medida((edad)::character varying)) STORED,
    CONSTRAINT perfiles_edad_pkey PRIMARY KEY (perfil_edad),
    CONSTRAINT perfiles_edad_uk UNIQUE (edad),
    CONSTRAINT "rango de edades válido para perfiles_edad" CHECK (edad ~ '^(?:1\s+año|(?:[02-9]\d*|\d{2,})\s+años)$'::text OR edad ~ '^\d+-\d+\s+(?:años|meses)$'::text OR edad ~ '^≥\s\d+\s+(?:años)$'::text OR edad ~ '^<\s\d+\s+(?:años)$'::text OR edad ~ '^>\s\d+\s+(?:años)$'::text)

 */
'use strict'

import { TableDefinition } from "backend-plus";

export const perfiles = (): TableDefinition => {
  return {
    editable: false,
    name: 'perfiles',
    schema: 'ccc',
    fields: [
      { name: 'perfil', typeName: 'integer', editable: false, sequence: { name: 'perfil_seq', firstValue: 1 } },
      { name: 'tipo', typeName: 'text', nullable: false },
      { name: 'genero', typeName: 'text', nullable: false },
      { name: 'edad', typeName: 'text', nullable: false },
      { name: 'energia', typeName: 'double' },
      { name: 'unidcons', typeName: 'double' },
      { name: 'edad_desde', typeName: 'integer', generatedAs: 'ccc.extraer_edad_desde((edad)::character varying)' },
      { name: 'edad_hasta', typeName: 'integer', generatedAs: 'ccc.extraer_edad_hasta((edad)::character varying)' },
      { name: 'edad_umed', typeName: 'text', generatedAs: 'ccc.extraer_unidad_medida((edad)::character varying)' },
      { name: 'descripcion', typeName: 'text', generatedAs: "concat(tipo, ' - ', genero, ' - ', edad)", isName: true},
      { name: 'equivalente', typeName: 'boolean' },
    ],
    primaryKey: ['perfil'],
    constraints: [
      { constraintType: 'unique', consName: 'debe haber un unico tipo, genero y edad', fields: ['tipo', 'genero', 'edad'] },
      { constraintType: 'check', consName: 'tipo debe ser Lactante, Menor o Adulto', expr: `tipo = ANY (ARRAY['Lactante'::text, 'Menor'::text, 'Adulto'::text])` },
      { constraintType: 'check', consName: 'género debe ser Varón, Mujer, Embarazo o Lactancia', expr: `genero = ANY (ARRAY['Varón'::text, 'Mujer'::text, 'Embarazo'::text, 'Lactancia'::text])` },
      { constraintType: 'check', consName: 'rango de edades válido', expr: `edad ~ '^(?:1\s+año|(?:[2-9]\d*|\d{2,})\s+años)$'::text OR edad ~ '^\d+-\d+\s+(?:años|meses)$'::text OR edad ~ '^≥\s\d+\s+(?:años)$'::text` },
    ],
  }
}
import * as backendPlus from "backend-plus";

// exposes APIs from this package
export * from "backend-plus";

export interface InternalData {
  filterActualPeriodo: string;
}

export interface Backend extends backendPlus.AppBackend {
  internalData: InternalData;
}

export interface Context extends backendPlus.Context {
  be: Backend;
}
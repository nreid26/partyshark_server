part of model;

abstract class PartysharkEntity {
  final PartysharkModel __model;
  final int identity;

  Logger get logger => __model.logger;

  PartysharkEntity(this.__model, this.identity);
}
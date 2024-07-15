//Tipos de dados
import 'dart:math';

import 'package:topografia/Codigos/geradorDePoligonos.dart';

typedef ClassValue = double Function(int value);
typedef ClassValueDouble = double Function(double value);

List<Map> unidades = [
  {
    'name': 'km',
    'inM': 1000.0,
  },
  {
    'name': 'hm',
    'inM': 100.0,
  },
  {
    'name': 'dam',
    'inM': 10.0,
  },
  {
    'name': 'm',
    'inM': 1.0,
  },
  {
    'name': 'dm',
    'inM': 0.1,
  },
  {
    'name': 'cm',
    'inM': 0.01,
  },
  {
    'name': 'mm',
    'inM': 0.001,
  },
  {
    'name': 'in',
    'inM': 0.0254,
  },
  {
    'name': 'ft',
    'inM': 0.3048,
  },
  {
    'name': 'yd',
    'inM': 0.9144,
  },
  {
    'name': 'mi',
    'inM': 1609.34,
  },
  {
    'name': 'léguas',
    'inM': 6600.0,
  },
  {
    'name': 'braças',
    'inM': 2.2,
  },
  {
    'name': 'léguas marítmas',
    'inM': 5555.55,
  },
  {
    'name': 'quadras',
    'inM': 132.0,
  },
  {
    'name': 'cordas',
    'inM': 33.0,
  },
  {
    'name': 'varas',
    'inM': 1.1,
  },
  {
    'name': 'palmos',
    'inM': 0.22,
  }
];

List<Map> unidadesArea = [
  {
    'name': 'litro',
    'inHa': 0.0605,
  },
  {
    'name': 'prato',
    'inHa': 0.0968,
  },
  {
    'name': 'Palmo de Sesmaria',
    'inHa': 0.1452,
  },
  {
    'name': 'Meia Quarta',
    'inHa': 0.3025,
  },
  {
    'name': 'Quarta de Terra',
    'inHa': 0.6050,
  },
  {
    'name': 'Hectare de Terra',
    'inHa': 1.0,
  },
  {
    'name': 'Meio Alqueire',
    'inHa': 1.21,
  },
  {
    'name': 'Braça de Sesmaria',
    'inHa': 1.4520,
  },
  {
    'name': 'Quadra Quadrada',
    'inHa': 1.7424,
  },
  {
    'name': 'Alqueire Paulista ou Menor',
    'inHa': 2.4200,
  },
  {
    'name': 'Alqueire Mineiro ou Geométrico',
    'inHa': 4.8400,
  },
  {
    'name': 'Lote Colonial',
    'inHa': 24.2000,
  },
  {
    'name': 'Quadra de Sesmaria',
    'inHa': 87.1200,
  },
  {
    'name': 'Milhão de Metro',
    'inHa': 100.0000,
  },
  {
    'name': 'Data de Campo',
    'inHa': 272.2500,
  },
  {
    'name': 'Data de Mato',
    'inHa': 544.5000,
  },
  {
    'name': 'Sesmaria de Mato',
    'inHa': 1089.0000,
  },
];

const double earthRadius = 6367000; //Em metros

const double constAparelho = 100;

Map<String, ClassValue> classesLevantamneto = {
  "IP": (val) {
    return gmsToDoube("0°0'6\"") * sqrt(val);
  },
  "IIP": (val) {
    return gmsToDoube("0°0'15\"") * sqrt(val);
  },
  "IIIP": (val) {
    return gmsToDoube("0°0'20\"") * sqrt(val);
  },
  "IVP": (val) {
    return gmsToDoube("0°0'40\"") * sqrt(val);
  },
  "VP": (val) {
    return gmsToDoube("0°3'0\"") * sqrt(val);
  },
};

Map<String, ClassValueDouble> tolLinearMax = {
  "IP": (val) {
    return 0.1 * sqrt(val);
  },
  "IIP": (val) {
    return 0.3 * sqrt(val);
  },
  "IIIP": (val) {
    return 0.42 * sqrt(val);
  },
  "IVP": (val) {
    return 0.56 * sqrt(val);
  },
  "VP": (val) {
    return 2.2 * sqrt(val);
  },
};

Map<String, List<num>> folhas = {
  "A0": [118.9, 84.1],
  "A1": [84.1, 59.4],
  "A2": [59.4, 42],
  "A3": [42, 29.7],
  "A4": [29.7, 21],
};

Map<String, num> escalas = {
  //"1000:1": 1000 / 1,
  //"500:1": 500 / 1,
  //"400:1": 400 / 1,
  //"300:1": 300 / 1,
  //"200:1": 200 / 1,
  //"100:1": 100 / 1,
  //"75:1": 75 / 1,
  //"50:1": 50 / 1,
  ///"40:1": 40 / 1,
  //"20:1": 20 / 1,
  //"10:1": 10 / 1,
  //"5:1": 5 / 1,
  //"1:1": 1 / 1,
  //"1:5": 1 / 5,
  //"1:10": 1 / 10,
  //"1:20": 1 / 20,
  "1:25": 1 / 25,
  //"1:40": 1 / 40,
  "1:50": 1 / 50,
  "1:75": 1 / 75,
  "1:100": 1 / 100,
  "1:150": 1 / 150,
  "1:200": 1 / 200,
  "1:250": 1 / 250,
  //"1:300": 1 / 300,
  //"1:400": 1 / 400,
  "1:500": 1 / 500,
  "1:750": 1 / 750,
  "1:1000": 1 / 1000,
};

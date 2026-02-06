export const millisecond = 1;
export const second = millisecond * 1000;
export const minute = second * 60;
export const hour = minute * 60;
export const day = hour * 24;

export const nonNullable = <T>(value: T): value is NonNullable<T> =>
  value != null;

export function delay(time: number) {
  return new Promise(function (resolve) {
    setTimeout(resolve, time);
  });
}

export function chunk<T>(source: T[], offset: number): T[][] {
  const duplicated = [...source];
  const result: T[][] = [];
  let length = duplicated.length;

  while (0 < length) {
    result.push(duplicated.splice(0, offset));
    length = duplicated.length;
  }
  return result;
}

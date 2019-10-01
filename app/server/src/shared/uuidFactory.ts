import uuid from 'uuid/v4';

export const generateUserId = () => 'rgb.user.' + uuid();

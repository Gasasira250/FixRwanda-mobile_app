function attachRealtime(io) {
  io.on('connection', (socket) => {
    socket.on('join_job', (bookingId) => {
      if (bookingId) socket.join(`job:${bookingId}`);
    });
    socket.on('provider_location', (payload = {}) => {
      const { bookingId, lat, lng } = payload;
      if (!bookingId || lat == null || lng == null) return;
      io.to(`job:${bookingId}`).emit('location', {
        bookingId,
        lat,
        lng,
        at: new Date().toISOString(),
      });
    });
  });

  return {
    publishLocation(bookingId, { lat, lng }) {
      io.to(`job:${bookingId}`).emit('location', {
        bookingId,
        lat,
        lng,
        at: new Date().toISOString(),
      });
    },
  };
}

module.exports = { attachRealtime };

/// Appends an event and retains the newest suffix at the caller's limit.
void appendRetainedEvent<T>(List<T> events, T event, int maxEvents) {
  events.add(event);
  if (events.length > maxEvents) {
    events.removeRange(0, events.length - maxEvents);
  }
}
